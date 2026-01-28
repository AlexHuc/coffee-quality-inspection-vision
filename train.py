#!/usr/bin/env python
# coding: utf-8

# # 0. Importing the libs and read the data
# Core Libraries
from collections import defaultdict
import matplotlib.pyplot as plt
from pathlib import Path
from PIL import Image
import pandas as pd
import numpy as np
import shutil
import random
import math
import json
import os

# ML Libraries
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
from torch.utils.data import DataLoader, Dataset
import torchvision.transforms as transforms
import torchvision.models as models
from datetime import datetime
import torch.optim as optim
import torch.nn as nn
import seaborn as sns
import torch


# # 1. EDA & Data preparation
# ### Loading a sample of each category
RAW_DIR = "data/raw"


# # 2. Transfer Learning & Model Training
# 
# ### Project Overview
# - **Goal**: Detect and classify 17 different types of defects in Arabica green coffee beans
# - **Approach**: Transfer learning with pretrained models (ResNet50, EfficientNet, MobileNet, ConvNeXt)
# - **Dataset**: 962 images total (train: 60%, val: 20%, test: 20%)
# - **Output**: Trained models with performance comparison
# 
# ### Check GPU availability
# Check GPU availability
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ### Create models folder
models_dir = "models"
os.makedirs(models_dir, exist_ok=True)

# ### Data Loading and Preprocessing
class CoffeeDefectDataset(Dataset):
    """A custom dataset class for loading coffee defect images."""

    def __init__(self, image_dir, transform=None):
        """
            image_dir: Path to the directory containing images organized in class subdirectories.
            transform: Optional torchvision transforms to apply to the images.
        """
        self.image_paths = []
        self.labels = []
        self.classes = sorted([d for d in os.listdir(image_dir) if os.path.isdir(os.path.join(image_dir, d))])
        self.class_to_idx = {cls: idx for idx, cls in enumerate(self.classes)}

        for class_idx, class_name in enumerate(self.classes):
            class_path = os.path.join(image_dir, class_name)
            for img_name in os.listdir(class_path):
                if img_name.lower().endswith((".png", ".jpg", ".jpeg")):
                    self.image_paths.append(os.path.join(class_path, img_name))
                    self.labels.append(class_idx)

        self.transform = transform

    def __len__(self):
        """Returns the total number of images in the dataset."""
        return len(self.image_paths)

    def __getitem__(self, idx):
        """Returns the image and label at the specified index."""
        from PIL import Image
        img = Image.open(self.image_paths[idx]).convert("RGB")
        label = self.labels[idx]

        if self.transform:
            img = self.transform(img)

        return img, label

# ### Define data augmentations and transformations
train_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomHorizontalFlip(p=0.3),
    transforms.RandomRotation(15),
    transforms.ColorJitter(brightness=0.2, contrast=0.2),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                        std=[0.229, 0.224, 0.225])
])

val_test_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                        std=[0.229, 0.224, 0.225])
])


# ### Load datasets with transformations
train_dataset = CoffeeDefectDataset("data/processed/train", transform=train_transform)
val_dataset = CoffeeDefectDataset("data/processed/val", transform=val_test_transform)
test_dataset = CoffeeDefectDataset("data/processed/test", transform=val_test_transform)

# ### Model Initialization and Training Framework
def get_pretrained_model(model_name, num_classes=17, freeze_backbone=True):
    """Load pretrained model and modify for coffee defect classification"""

    if model_name == "resnet50":
        model = models.resnet50(pretrained=True)
        num_features = model.fc.in_features
        model.fc = nn.Linear(num_features, num_classes)

    elif model_name == "efficientnet_b0":
        model = models.efficientnet_b0(pretrained=True)
        num_features = model.classifier[1].in_features
        model.classifier[1] = nn.Linear(num_features, num_classes)

    elif model_name == "efficientnet_b2":
        model = models.efficientnet_b2(pretrained=True)
        num_features = model.classifier[1].in_features
        model.classifier[1] = nn.Linear(num_features, num_classes)

    elif model_name == "mobilenet_v3":
        model = models.mobilenet_v3_large(pretrained=True)
        num_features = model.classifier[3].in_features
        model.classifier[3] = nn.Linear(num_features, num_classes)

    elif model_name == "convnext_tiny":
        model = models.convnext_tiny(pretrained=True)
        num_features = model.classifier[2].in_features
        model.classifier[2] = nn.Linear(num_features, num_classes)

    else:
        raise ValueError(f"Unknown model: {model_name}")

    # Freeze backbone weights if specified
    if freeze_backbone:
        for param in model.parameters():
            param.requires_grad = False

        # Unfreeze classifier layer
        if model_name == "resnet50":
            for param in model.fc.parameters():
                param.requires_grad = True
        elif model_name.startswith("efficientnet"):
            for param in model.classifier.parameters():
                param.requires_grad = True
        elif model_name == "mobilenet_v3":
            for param in model.classifier.parameters():
                param.requires_grad = True
        elif model_name == "convnext_tiny":
            for param in model.classifier.parameters():
                param.requires_grad = True

    return model

# ### Model Training Class
class ModelTrainer:
    """Training framework for transfer learning models"""

    def __init__(self, model, train_loader, val_loader, test_loader, device, model_name):
        """
        Initialize the ModelTrainer with model and data loaders. 
            model: PyTorch model to train
            train_loader: DataLoader for training data
            val_loader: DataLoader for validation data
            test_loader: DataLoader for test data
            device: Device to run the model on (CPU or GPU)
            model_name: Name of the model architecture
        """
        self.model = model.to(device)
        self.train_loader = train_loader
        self.val_loader = val_loader
        self.test_loader = test_loader
        self.device = device
        self.model_name = model_name
        self.history = {
            'train_loss': [],
            'train_acc': [],
            'val_loss': [],
            'val_acc': [],
            'test_loss': None,
            'test_acc': None
        }

    def train_epoch(self, optimizer, criterion):
        """
        Train the model for one epoch.
            optimizer: Optimizer for updating model weights
            criterion: Loss function
        """
        self.model.train()
        total_loss = 0
        correct = 0
        total = 0

        for images, labels in self.train_loader:
            images, labels = images.to(self.device), labels.to(self.device)

            optimizer.zero_grad()
            outputs = self.model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            total_loss += loss.item()
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

        avg_loss = total_loss / len(self.train_loader)
        accuracy = correct / total
        return avg_loss, accuracy

    def validate(self, criterion):
        """
        Validate the model on the validation set.
            criterion: Loss function
        """
        self.model.eval()
        total_loss = 0
        correct = 0
        total = 0

        with torch.no_grad():
            for images, labels in self.val_loader:
                images, labels = images.to(self.device), labels.to(self.device)
                outputs = self.model(images)
                loss = criterion(outputs, labels)

                total_loss += loss.item()
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()

        avg_loss = total_loss / len(self.val_loader)
        accuracy = correct / total
        return avg_loss, accuracy

    def test(self, criterion):
        """
        Test the model on the test set.
            criterion: Loss function
        """
        self.model.eval()
        total_loss = 0
        correct = 0
        total = 0
        all_preds = []
        all_labels = []

        with torch.no_grad():
            for images, labels in self.test_loader:
                images, labels = images.to(self.device), labels.to(self.device)
                outputs = self.model(images)
                loss = criterion(outputs, labels)

                total_loss += loss.item()
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()

                all_preds.extend(predicted.cpu().numpy())
                all_labels.extend(labels.cpu().numpy())

        avg_loss = total_loss / len(self.test_loader)
        accuracy = correct / total

        self.history['test_loss'] = avg_loss
        self.history['test_acc'] = accuracy

        return avg_loss, accuracy, all_preds, all_labels

    def train(self, num_epochs=20, learning_rate=0.001, weight_decay=0):
        """
        Train the model for a specified number of epochs.
            num_epochs: Number of epochs to train
            learning_rate: Learning rate for the optimizer
            weight_decay: Weight decay (L2 regularization) for the optimizer
        """
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.Adam(filter(lambda p: p.requires_grad, self.model.parameters()), 
                               lr=learning_rate, weight_decay=weight_decay)

        best_val_acc = 0
        patience = 5
        patience_counter = 0

        for epoch in range(num_epochs):
            train_loss, train_acc = self.train_epoch(optimizer, criterion)
            val_loss, val_acc = self.validate(criterion)

            self.history['train_loss'].append(train_loss)
            self.history['train_acc'].append(train_acc)
            self.history['val_loss'].append(val_loss)
            self.history['val_acc'].append(val_acc)

            if (epoch + 1) % 5 == 0:
                print(f"Epoch [{epoch+1}/{num_epochs}] - "
                      f"Train Loss: {train_loss:.4f}, Train Acc: {train_acc:.4f} | "
                      f"Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.4f}")

            # Early stopping
            if val_acc > best_val_acc:
                best_val_acc = val_acc
                patience_counter = 0
            else:
                patience_counter += 1
                if patience_counter >= patience:
                    print(f"Early stopping at epoch {epoch+1}")
                    break

        return self.history


# ### Training Configuration, Model Training and Fine-Tunning
# Training Configurations - EXPANDED with granular hyperparameters
# Format: (model_name, batch_size, learning_rate, num_epochs, weight_decay)
training_configs = [
    # # ResNet50 - varied batch sizes and learning rates
    # ("resnet50", 8, 0.001, 20, 1e-4),
    # ("resnet50", 16, 0.001, 20, 1e-4),
    # ("resnet50", 16, 0.0005, 20, 1e-4),
    # ("resnet50", 32, 0.001, 20, 1e-4),
    # ("resnet50", 32, 0.0005, 20, 1e-5),
    # ("resnet50", 64, 0.0005, 20, 1e-4),
    # ("resnet50", 16, 0.002, 15, 1e-4),

    # # EfficientNet-B0 - varied batch sizes and learning rates
    # ("efficientnet_b0", 8, 0.001, 20, 1e-4),
    # ("efficientnet_b0", 16, 0.001, 20, 1e-4),
    # ("efficientnet_b0", 16, 0.0005, 20, 1e-4),
    # ("efficientnet_b0", 32, 0.001, 20, 1e-4),
    # ("efficientnet_b0", 32, 0.0005, 20, 1e-5),
    # ("efficientnet_b0", 32, 0.0001, 25, 1e-4),
    # ("efficientnet_b0", 64, 0.0005, 20, 1e-4),

    # # EfficientNet-B2 - varied batch sizes and learning rates
    # ("efficientnet_b2", 8, 0.001, 20, 1e-4),
    # ("efficientnet_b2", 16, 0.001, 20, 1e-4),
    # ("efficientnet_b2", 16, 0.0005, 20, 1e-5),
    # ("efficientnet_b2", 32, 0.0005, 20, 1e-4),
    # ("efficientnet_b2", 32, 0.0001, 25, 1e-4),
    # ("efficientnet_b2", 64, 0.0005, 20, 1e-4),

    # # MobileNet-v3 - varied batch sizes and learning rates
    # ("mobilenet_v3", 16, 0.001, 20, 1e-4),
    # ("mobilenet_v3", 32, 0.001, 20, 1e-4),
    # ("mobilenet_v3", 32, 0.0005, 20, 1e-5),
    # ("mobilenet_v3", 64, 0.001, 20, 1e-4),
    # ("mobilenet_v3", 64, 0.0005, 20, 1e-4),
    # ("mobilenet_v3", 32, 0.002, 15, 1e-4),
    # ("mobilenet_v3", 16, 0.0001, 25, 1e-4),

    # ConvNeXt-Tiny - varied batch sizes and learning rates
    ("convnext_tiny", 8, 0.001, 20, 1e-4),
    # ("convnext_tiny", 16, 0.001, 20, 1e-4),
    # ("convnext_tiny", 16, 0.0005, 20, 1e-4),
    # ("convnext_tiny", 32, 0.001, 20, 1e-4),
    # ("convnext_tiny", 32, 0.0005, 20, 1e-5),
    # ("convnext_tiny", 32, 0.0001, 25, 1e-4),
    # ("convnext_tiny", 64, 0.0005, 20, 1e-4),
    # ("convnext_tiny", 16, 0.002, 15, 1e-4),
]

# Dictionary to store all trained models and their results
results = {}

# ### Training loop for all configurations
for idx, (model_name, batch_size, lr, epochs, wd) in enumerate(training_configs):
    print(f"\n{'='*80}")
    print(f"[{idx+1}/{len(training_configs)}] Training: {model_name} | BS={batch_size} | LR={lr} | WD={wd}")
    print(f"{'='*80}")

    # Create data loaders
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)

    # Initialize model
    model = get_pretrained_model(model_name, num_classes=17, freeze_backbone=True)

    # Create trainer
    trainer = ModelTrainer(model, train_loader, val_loader, test_loader, device, model_name)

    # Train model
    history = trainer.train(num_epochs=epochs, learning_rate=lr, weight_decay=wd)

    # Test model
    test_loss, test_acc, all_preds, all_labels = trainer.test(nn.CrossEntropyLoss())

    # Generate model name with parameters
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    model_filename = f"best_model_{model_name}_bs{batch_size}_lr{lr}_acc{test_acc:.4f}_{timestamp}.pt"
    model_path = os.path.join(models_dir, model_filename)

    # Save model
    torch.save(model.state_dict(), model_path)

    # Store results
    config_key = f"{model_name}_bs{batch_size}_lr{lr}"
    results[config_key] = {
        "model_name": model_name,
        "batch_size": batch_size,
        "learning_rate": lr,
        "weight_decay": wd,
        "epochs": epochs,
        "test_accuracy": test_acc,
        "test_loss": test_loss,
        "model_path": model_path,
        "history": history,
        "predictions": all_preds,
        "labels": all_labels
    }

    print(f"\nModel saved: {model_filename}")
    print(f"Test Accuracy: {test_acc:.4f}")
    print(f"Test Loss: {test_loss:.4f}")

print(f"\n{'='*80}")
print(f"All {len(training_configs)} models trained successfully!")
print(f"{'='*80}")
