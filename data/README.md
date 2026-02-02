# Data Documentation - Coffee Bean Defect Detection

This directory contains the coffee bean dataset organized for model training and evaluation. Data is split into two folders: `raw/` (original dataset) and `processed/` (split into train/test sets).

## 📂 Directory Structure

```
data/
├── raw/                                     # Original unmodified images from source
│   ├── Broken/                              # 17 defect categories
│   ├── Cut/
│   ├── Dry Cherry/
│   ├── Fade/
│   ├── Floater/
│   ├── Full Black/
│   ├── Full Sour/
│   ├── Fungus Damange/
│   ├── Husk/
│   ├── Immature/
│   ├── Parchment/
│   ├── Partial Black/
│   ├── Partial Sour/
│   ├── Severe Insect Damange/
│   ├── Shell/
│   ├── Slight Insect Damage/
│   └── Withered/
│
└── processed/                               # Train/Test split with standardized format
    ├── train/                               # Training dataset
    │   ├── Broken/
    │   ├── Cut/
    │   ├── Dry Cherry/
    │   ├── ... (all 17 defect classes)
    │   └── [normalized, resized]
    │
    └── test/                                # Testing dataset
        ├── Broken/
        ├── Cut/
        ├── Dry Cherry/
        ├── ... (all 17 defect classes)
        └── [normalized, resized]
```

---

## 📊 Data Organization

### Raw Data (`raw/` folder)

The `raw/` folder contains **original, unmodified images** directly from the source dataset.

#### Characteristics:
- **Format**: JPG image files
- **Resolution**: 500×500 pixels
- **File Naming**: `{ClassName}_{Number}.jpg` (e.g., `Broken_01.jpg`, `Broken_02.jpg`)
- **Organization**: One subfolder per defect class (17 categories)
- **Color Space**: RGB (3 channels)
- **Defect Classes**: 17 categories (Broken, Cut, Dry Cherry, Fade, Floater, Full Black, Full Sour, Fungus Damange, Husk, Immature, Parchment, Partial Black, Partial Sour, Severe Insect Damange, Shell, Slight Insect Damage, Withered)

#### Purpose:
- **Single Source of Truth**: Original dataset preserved in pristine form
- **Reproducibility**: Enables verification against source data
- **Flexibility**: Allows regeneration of processed data if needed
- **Auditability**: Maintains data lineage and integrity
- **Backup Reference**: Original source for recovery if needed

#### Raw Data Classes:
```
raw/
├── Broken/                   # Fractured or split beans
├── Cut/                      # Beans with cuts or nicks
├── Dry Cherry/               # Incompletely processed beans
├── Fade/                     # Discolored beans lacking vibrancy
├── Floater/                  # Low-density beans that float
├── Full Black/               # Completely dark/black beans
├── Full Sour/                # Fermented beans with sour defects
├── Fungus Damange/           # Mold or fungal infections
├── Husk/                     # Beans with parchment/husk
├── Immature/                 # Under-ripened beans
├── Parchment/                # Incompletely removed parchment
├── Partial Black/            # Partially dark beans
├── Partial Sour/             # Partially fermented beans
├── Severe Insect Damange/    # Heavy pest damage
├── Shell/                    # Incomplete bean shells
├── Slight Insect Damage/     # Minor pest marks
└── Withered/                 # Dried/shriveled beans
```

#### Example Raw File Structure:
```
raw/Broken/
├── Broken_01.jpg            # 500×500 px, original quality
├── Broken_02.jpg
├── Broken_03.jpg
├── Broken_04.jpg
├── Broken_05.jpg
└── ... (multiple images per class)

raw/Cut/
├── Cut_01.jpg
├── Cut_02.jpg
└── ...
```

---

### Processed Data (`processed/` folder)

The `processed/` folder contains **train/test split data** with standardized preprocessing applied.

#### Structure:

1. **Train Set** (`processed/train/`)
   - Contains ~80% of images from each class
   - Used for model training
   - Organized by defect class
   - Undergoes data augmentation during training

2. **Test Set** (`processed/test/`)
   - Contains ~20% of images from each class
   - Used for model evaluation
   - Organized by defect class
   - No augmentation (true evaluation)

#### Preprocessing Applied:

1. **Train/Test Split**
   - ~80/20 split from original raw data
   - Stratified sampling (maintains class balance)
   - Ensures reproducibility

2. **Image Standardization**
   - All images resized to **224×224 pixels**
   - Maintains aspect ratio with padding if needed
   - Consistent input size for neural networks

3. **Format Consistency**
   - All images in JPG format
   - Consistent quality encoding
   - Standardized file naming

4. **Color Space**
   - All images RGB (3 channels)
   - Normalized to [0, 255] range
   - Ready for normalization in training

#### Characteristics:
- **Format**: JPG (standardized)
- **Resolution**: 224×224 pixels (fixed)
- **Organization**: train/ and test/ folders with 17 class subfolders each
- **Naming**: Maintains original `{ClassName}_{Number}.jpg` format
- **Color Space**: RGB (3 channels)
- **Use Case**: Direct input for model training/evaluation

#### Purpose:
- **Model Training**: Optimized for neural network input pipeline
- **Consistency**: All images have identical properties and size
- **Efficiency**: Preprocessing done once, not during each epoch
- **Reproducibility**: Consistent preprocessing ensures repeatable results
- **Faster Training**: Reduced I/O overhead with standardized format

#### Example Processed File Structure:
```
processed/train/Broken/
├── Broken_01.jpg            # 224×224 px, standardized
├── Broken_02.jpg
├── Broken_03.jpg
├── Broken_04.jpg
├── Broken_05.jpg
└── ... (training images)

processed/test/Broken/
├── Broken_06.jpg            # 224×224 px, standardized
├── Broken_07.jpg
└── ... (test images)
```

---

## 🔄 Raw vs. Processed: Why Two Folders?

### Key Differences

| Aspect | Raw | Processed |
|--------|-----|-----------|
| **Source** | Original dataset | Train/Test split from raw |
| **Modification** | None - untouched | Heavy preprocessing + split |
| **Resolution** | 500×500 pixels | 224×224 pixels |
| **Train/Test Split** | Not split | 80/20 stratified split |
| **File Size** | Original size | Reduced (smaller resolution) |
| **Use Case** | Reference/Archive | Model training & evaluation |
| **Access Pattern** | Infrequent | Frequent (every epoch) |
| **Storage** | Long-term archival | Active working directory |

### Advantages of This Separation

#### 1. **Data Integrity & Reproducibility**
- **Raw folder**: Preserves original data untouched for verification
- **Processed folder**: Consistent preprocessing for repeatable results
- Enables comparison against source dataset
- Supports academic reproducibility standards
- Facilitates data provenance tracking

#### 2. **Efficient Development Workflow**
- **Raw data**: One-time organization (already done)
- **Processed data**: Used for all training experiments
- Separates data preparation from model development
- Allows parallel experimentation on processed data
- Reduces preprocessing overhead (done once, used many times)

#### 3. **Flexible Experimentation**
- **Maintain raw data** while experimenting with different preprocessing
- Test various image sizes without re-organizing raw data
- Evaluate different train/test split strategies
- Compare preprocessing approaches
- All without losing the original source

#### 4. **Storage & Performance Optimization**
- **Raw folder**: Archived for reference (~1-2GB)
- **Processed folder**: Optimized for training (~200-300MB)
- Faster I/O during training (smaller image files)
- Reduces time per epoch
- Efficient disk space usage

#### 5. **Quality Control**
- **Raw folder**: Validation against source integrity
- **Processed folder**: Verification of preprocessing correctness
- Enables detection of corrupted or invalid images
- Allows debugging of preprocessing issues
- Facilitates train/test split verification

#### 6. **Multi-Experiment Support**
- Different models may need different input sizes
- Can maintain multiple processed versions simultaneously
- Raw data remains as single source of truth
- Scales to multiple preprocessing strategies
- Enables A/B testing of preprocessing approaches

---

## 📥 Data Pipeline

### Complete Training Data Flow

```
1. ORIGINAL DATA
   └─> data/raw/
       └─> 17 defect class folders
           └─> Original 500×500 images

2. PREPROCESSING & SPLIT
   └─> Read from raw/
       ├─> Resize to 224×224
       ├─> Standardize format (JPG)
       ├─> Split: 80% train / 20% test
       └─> Write to processed/train/ and processed/test/

3. MODEL TRAINING
   └─> Read from processed/train/
       ├─> Load batch of images
       ├─> Apply data augmentation (random rotations, flips, etc.)
       ├─> Normalize pixel values (mean/std)
       ├─> Create tensors
       └─> Feed to neural network

4. MODEL EVALUATION
   └─> Read from processed/test/
       ├─> Load batch of images
       ├─> NO augmentation (true evaluation)
       ├─> Normalize pixel values (same as training)
       ├─> Create tensors
       └─> Evaluate model accuracy
```

---

## 📊 Dataset Statistics

### Class Distribution

Each defect class has multiple images distributed across train/test sets:

```
Example Distribution (approximate):
- Broken: ~100 images total (80 train, 20 test)
- Cut: ~100 images total (80 train, 20 test)
- Dry Cherry: ~100 images total (80 train, 20 test)
- ... (consistent ~100 per class)
- Total: ~1,700 images (1,360 train, 340 test)

Note: Exact counts may vary based on original dataset
```

### Storage Requirements

```
Raw Data:
- ~1-2 GB total (500×500 images, original quality)

Processed Data:
- ~200-300 MB (224×224 resized images)
- train/: ~160-240 MB
- test/: ~40-60 MB

Combined:
- Total disk space needed: ~1.5-2.5 GB
```

---

## 🚀 Using the Data in Training

### Loading Data in Python

```python
from torchvision import datasets, transforms
from torch.utils.data import DataLoader

# Define transforms for training
train_transforms = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomRotation(15),
    transforms.RandomHorizontalFlip(),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

# Define transforms for testing (no augmentation)
test_transforms = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])

# Load training dataset
train_dataset = datasets.ImageFolder('data/processed/train/', transform=train_transforms)
train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)

# Load testing dataset
test_dataset = datasets.ImageFolder('data/processed/test/', transform=test_transforms)
test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)

# Verify class mapping
print(f"Classes: {train_dataset.classes}")
print(f"Number of classes: {len(train_dataset.classes)}")
```