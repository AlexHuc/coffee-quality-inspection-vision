import torch
import torch.nn as nn
import torchvision.transforms as T
import torchvision.models as models
from flask import Flask, request, jsonify
from PIL import Image
import os
from datetime import datetime

app = Flask("coffee-defect-predictor")

DEVICE = torch.device("cpu")

NUM_CLASSES = 17
CLASS_NAMES = [
    "black", 
    "broken", 
    "immature", 
    "insect_damage", 
    "mold",
    "sour", 
    "shell", 
    "shrivelled", 
    "fungus",
    "cut", 
    "floater", 
    "overfermented", 
    "stones",
    "foreign_matter", 
    "severe_damage", 
    "mild_damage", 
    "healthy"
]

# ======================
# LOAD MODEL
# ======================
def load_model():
    model = models.convnext_tiny(pretrained=False)
    model.classifier[2] = nn.Linear(model.classifier[2].in_features, NUM_CLASSES)

    model.load_state_dict(
        torch.load("models/best_model_convnext_tiny_bs8_lr0.001_acc0.7295_20260128_213109.pt", map_location=DEVICE)
    )
    model.eval()
    return model

model = load_model()

# ======================
# TRANSFORM
# ======================
transform = T.Compose([
    T.Resize((224, 224)),
    T.ToTensor(),
    T.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

# ======================
# HEALTH
# ======================
@app.route("/health")
def health():
    return jsonify({
        "status": "ok",
        "timestamp": str(datetime.now())
    })

# ======================
# PREDICT
# ======================
@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "no file"}), 400

    img = Image.open(request.files["file"]).convert("RGB")
    x = transform(img).unsqueeze(0)

    with torch.no_grad():
        logits = model(x)
        probs = torch.softmax(logits, dim=1)
        conf, pred = torch.max(probs, dim=1)

    return jsonify({
        "class_id": int(pred.item()),
        "class_name": CLASS_NAMES[pred.item()],
        "confidence": float(conf.item())
    })
