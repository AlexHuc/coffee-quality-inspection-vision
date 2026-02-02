# ☕ Coffee Bean Defect Detection using Deep Learning

Automatic quality inspection of **Arabica green coffee beans** using deep learning and computer vision techniques for detecting and classifying defects in real-time.

### Example of Input → Models → Outputs
![Coffee Bean Inspection](./imgs/coffee_inspection.png)

## Description of the Problem

### Background
Manual inspection of coffee beans during quality control is time-consuming, subjective, and difficult to scale. Coffee processors and exporters need to screen hundreds of beans per batch, which requires trained personnel and is prone to human error. Automating defect detection enables faster, objective, and scalable quality assurance.

### Problem Statement
Coffee quality inspectors and supply chain managers need a system to:

- **Detect Defective Beans** automatically from coffee bean images
- **Classify Defect Types** into one of 17 specific categories
- **Provide Confidence Scores** for each prediction
- **Scale Analysis**: Process thousands of beans automatically without manual inspection
- **Enable Industrial Integration**: Deploy via API or containerized services for production environments

### Solution Approach
This project implements a **deep learning classification pipeline** using state-of-the-art CNN architectures:

1. **Data Preparation**: Raw bean images (500×500 pixels) are preprocessed and normalized
2. **Model Training**: Multiple CNN architectures (ConvNeXt, EfficientNet, MobileNet, ResNet) are trained on 17 defect classes
3. **Model Evaluation**: Best-performing model selected based on validation accuracy
4. **Deployment**: Flask API and containerized services for scalable predictions via Kubernetes/Docker

The pipeline processes bean images through trained models and outputs defect classifications with confidence scores.

### Business Impact
- **Coffee Processors**: Automated defect detection reduces quality control time by 80%+
- **Export Operations**: Ensures compliance with international quality standards (specialty coffee grading)
- **Cost Reduction**: Eliminates need for multiple quality inspectors per processing line
- **Scalability**: Process unlimited beans per day without additional human resources
- **Data-Driven Insights**: Generate statistics on defect distributions and quality trends

---

## 🧠 Defect Classes

The system classifies beans into **17 defect categories**:

1. **Broken** - Fractured or split beans
2. **Cut** - Beans with cuts or nicks
3. **Dry Cherry** - Incompletely processed beans
4. **Fade** - Discolored beans lacking vibrancy
5. **Floater** - Low-density beans that float in water
6. **Full Black** - Completely dark/black beans
7. **Full Sour** - Fermented beans with sour defects
8. **Fungus Damage** - Mold or fungal infections
9. **Husk** - Beans with parchment or husk
10. **Immature** - Under-ripened beans
11. **Parchment** - Incompletely removed parchment layer
12. **Partial Black** - Partially dark beans
13. **Partial Sour** - Partially fermented beans
14. **Severe Insect Damage** - Heavy pest damage
15. **Shell** - Incomplete bean shells
16. **Slight Insect Damage** - Minor pest marks
17. **Withered** - Dried/shriveled beans

---

## 🗂 Dataset

- **Image Resolution**: 500 × 500 pixels
- **Bean Type**: Arabica green beans
- **Number of Defect Classes**: 17
- **Dataset Source**: Academic research dataset (Mae Fah Luang University)
- **Image Format**: JPG/PNG

### Citation & Acknowledgment

If you use this dataset, please cite the original paper:

```
https://doi.org/10.1016/j.atech.2024.100680
```

This dataset was supported by Mae Fah Luang University under the National Science, Research, and Innovation Fund (NSRF) 2023, grant no. 662A03049.

---

## Instructions on How to Run the Project

### Prerequisites

#### System Requirements
- Python 3.11 or higher
- Docker (for containerization)
- Kubernetes & Minikube (for orchestration)
- 8GB RAM minimum
- 10GB free disk space
- GPU support (CUDA/cuDNN) optional for faster training

### Local Development Setup

#### 1. Environment Setup
```bash
# Create and activate virtual environment
python -m venv coffee_v
source coffee_v/bin/activate  # On Windows: coffee_v\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

#### 2. Data Setup
- Download/place coffee bean images in `data/raw/`
- Organize by defect class (17 folders, one per defect type)
- Run preprocessing to generate `data/processed/` with standardized images

#### 3. Run the Complete Pipeline

**Step 1: Data Analysis and Model Training**
```bash
# Open Jupyter notebook for visualization, EDA, and feature exploration
jupyter notebook notebook.ipynb
```

**Step 2: Train Models**
```bash
# Train CNN models (ConvNeXt, EfficientNet, MobileNet, ResNet) on the dataset
python train.py
```

This generates multiple trained models in `models/`:
- `best_model_convnext_tiny_bs8_lr0.001_acc0.7295_20260128_213109.pt` - Best performing model
- Additional model variants for comparison

**Step 3: Start the Prediction Service Locally**

**Build the Docker image**
```bash
docker build -t coffee-predictor -f deployment/flask/Dockerfile .
```

**Run the Docker container**
```bash
docker run -it --rm -p 9696:9696 coffee-predictor
```

The Flask API will be available at: `http://localhost:9696`

**Test the service**
- Health check: `curl -X GET http://localhost:9696/health`
- Make prediction: `curl -X POST -F "file=@image.jpg" http://localhost:9696/predict`

**Step 4: Kubernetes Deployment**

Deploy to Minikube from the project root:
```bash
./deployment/kubernetes/deploy.sh
```

This deploys the service with:
- Automatic pod restart on failure
- Resource limits (CPU: 250m-500m, Memory: 512Mi)
- Service exposure on port 9696
- Health checks every 30 seconds

For detailed Kubernetes setup, see `./deployment/kubernetes/README.md`

---

## 🚀 Cloud Deployment

Deploy to major cloud providers using Terraform:

### AWS Deployment
```bash
cd deployment/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS settings
terraform init && terraform apply
```
See `deployment/aws/README.md` for detailed AWS ECS/Fargate deployment.

### GCP Deployment
```bash
cd deployment/gcp
export GCP_PROJECT_ID="your-project-id"
gcloud services enable run.googleapis.com artifactregistry.googleapis.com
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```
See `deployment/gcp/README.md` for Cloud Run deployment on GCP.

### Azure Deployment
```bash
cd deployment/azure
az login
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Azure subscription details
terraform init && terraform apply
```
See `deployment/azure/README.md` for App Service or Container Instances deployment.

---

## API Usage

### Health Check
```bash
curl -X GET http://localhost:9696/health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2026-01-28 21:31:09.123456"
}
```

### Defect Classification

**Input:** Coffee bean image (JPG/PNG)  
**Output:** Defect class prediction with confidence score

**Example Request**
```bash
curl -X POST -F "file=@coffee_bean.jpg" http://localhost:9696/predict
```

**Example Response**
```json
{
  "class_id": 1,
  "class_name": "broken",
  "confidence": 0.8234
}
```

- `class_id`: Numeric ID of the defect class (0-16)
- `class_name`: Name of the detected defect
- `confidence`: Prediction confidence (0.0-1.0)

---

## 📊 Model Performance

### Best Model: ConvNeXt Tiny
- **Accuracy**: 72.95%
- **Architecture**: ConvNeXt (Tiny variant)
- **Batch Size**: 8
- **Learning Rate**: 0.001
- **Training Date**: 2026-01-28

### Model Comparison
| Model | Batch Size | LR | Accuracy | File |
|-------|-----------|-----|----------|------|
| ConvNeXt Tiny | 8 | 0.001 | **72.95%** | best_model_convnext_tiny_bs8_lr0.001_acc0.7295_20260128_213109.pt |
| ConvNeXt Tiny | 8 | 0.001 | 73.43% | convnext_tiny_bs8_lr0.001_acc0.7343_20260128_184446.pt |
| ConvNeXt Tiny | 16 | 0.001 | 71.01% | convnext_tiny_bs16_lr0.001_acc0.7101_20260128_184605.pt |
| EfficientNet B0 | 8 | 0.001 | 59.42% | efficientnet_b0_bs8_lr0.001_acc0.5942_20260128_182504.pt |
| MobileNet V3 | 16 | 0.001 | 61.35% | mobilenet_v3_bs16_lr0.001_acc0.6135_20260128_183751.pt |

---

## 🧰 Technologies Used

| Component | Technology |
|-----------|-----------|
| **Deep Learning** | PyTorch 2.10.0 |
| **Model Architectures** | ConvNeXt, EfficientNet, MobileNet, ResNet |
| **Image Processing** | OpenCV, Pillow |
| **Data Processing** | NumPy, Pandas, Scikit-learn |
| **Visualization** | Matplotlib, Seaborn |
| **Web Framework** | Flask |
| **Server** | Gunicorn |
| **Containerization** | Docker |
| **Orchestration** | Kubernetes, Minikube |
| **Cloud Deployment** | AWS (ECS/Fargate), GCP (Cloud Run), Azure (App Service) |
| **Infrastructure as Code** | Terraform |
| **Monitoring** | CloudWatch, Cloud Logging, Application Insights |

---

## 📁 Repository Structure

```
coffee-quality-inspection-vision/
│
├── data/                                    # Raw coffee bean images organized by defect type
│   ├── raw/                                 # Original unprocessed images
│   └── processed/                           # Preprocessed standardized images
│
├── models/                                  # Trained model weights
│   ├── best_model_convnext_tiny_*.pt       # Best performing model
│   ├── convnext_tiny_*.pt                  # ConvNeXt variants
│   ├── efficientnet_b0_*.pt                # EfficientNet variants
│   ├── mobilenet_v3_*.pt                   # MobileNet variants
│   ├── resnet_*.pt                         # ResNet variants
│   └── README.md
│
├── deployment/                              # Deployment configurations
│   ├── flask/                               # Flask API service
│   │   ├── Dockerfile                       # Container image
│   │   ├── Pipfile                          # Python dependencies
│   │   ├── Pipfile.lock
│   │   ├── predict.py                       # Flask prediction API
│   │   └── README.md
│   ├── kubernetes/                          # Kubernetes manifests
│   │   ├── deploy.sh                        # Automated deployment script
│   │   ├── deployment.yaml                  # K8s deployment config
│   │   └── README.md
│   ├── aws/                                 # AWS Terraform deployment
│   │   ├── main.tf                          # Main infrastructure
│   │   ├── variables.tf                     # Variable definitions
│   │   ├── outputs.tf                       # Output values
│   │   ├── ecs.tf                           # ECS Fargate setup
│   │   ├── alb.tf                           # Load balancer config
│   │   ├── terraform.tfvars.example         # Configuration template
│   │   └── README.md
│   ├── gcp/                                 # GCP Terraform deployment
│   │   ├── main.tf
│   │   ├── cloud-run.tf                     # Cloud Run service
│   │   ├── artifact-registry.tf             # Container registry
│   │   ├── terraform.tfvars.example
│   │   └── README.md
│   └── azure/                               # Azure Terraform deployment
│       ├── main.tf
│       ├── app-service.tf                   # App Service config
│       ├── container-registry.tf            # ACR setup
│       ├── terraform.tfvars.example
│       └── README.md
│
├── imgs/                                    # Visualization and documentation images
│   ├── coffee_inspection.png                # Project overview image
│   └── README.md
│
├── notebook.ipynb                           # Jupyter notebook for analysis and training
├── train.py                                 # Model training script
├── requirements.txt                         # Python dependencies
└── README.md                                # This file
```

---

## 🎯 Model Architecture

### CNN Architecture Stack
```
Input Image (500×500×3)
    ↓
Preprocessing (Normalize, Resize to 224×224)
    ↓
CNN Backbone (ConvNeXt/EfficientNet/MobileNet/ResNet)
    ├── Feature Extraction (multiple convolutional blocks)
    ├── Batch Normalization & Activation
    └── Global Average Pooling
    ↓
Classification Head
    ├── Dense Layer (in_features → 512)
    ├── ReLU Activation
    ├── Dropout (0.5)
    └── Output Layer (512 → 17 classes)
    ↓
Softmax
    ↓
Output: Class prediction + Confidence score
```

---

## 📈 Performance Metrics

- **Accuracy**: ~73% on test set
- **Precision/Recall**: Computed per defect class
- **F1-Score**: Weighted average across all classes
- **Inference Time**: ~50-100ms per image (CPU), ~10-20ms (GPU)
- **Throughput**: ~10-20 predictions/second per instance

---

## 🚀 Future Improvements

- **Multi-Bean Detection**: Object detection (YOLO/Faster R-CNN) to identify multiple beans in single image
- **Defect Severity**: Regression models to estimate severity levels (mild/moderate/severe)
- **Model Explainability**: Grad-CAM visualizations to highlight model focus regions
- **Real-Time Inference**: Edge deployment on IoT devices at processing facilities
- **Web Dashboard**: Interactive dashboard for quality control operators
- **Mobile App**: Mobile inference for on-site quality checks
- **Ensemble Models**: Combine multiple architectures for improved accuracy
- **Active Learning**: User feedback loop to continuously improve model

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests for:
- Model improvements and new architectures
- Additional defect classes
- Deployment optimizations
- Documentation enhancements

---

## 📄 Citation

If you use this project or dataset, please cite:

```bibtex
@dataset{coffee_defect_2024,
  title={Coffee Bean Defect Detection Dataset},
  author={Mae Fah Luang University},
  year={2024},
  doi={10.1016/j.atech.2024.100680}
}
```

---

## 📞 Support

For issues, questions, or suggestions, please refer to the individual deployment README files:
- Local/Kubernetes: `./deployment/kubernetes/README.md`
- AWS: `./deployment/aws/README.md`
- GCP: `./deployment/gcp/README.md`
- Azure: `./deployment/azure/README.md`