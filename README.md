# ☕ Coffee Bean Defect Detection using Deep Learning

This project focuses on automatic quality inspection of **Arabica green coffee beans** using deep learning and computer vision techniques.

The goal is to detect and classify **17 different types of defects** commonly found in green coffee beans, supporting automated quality control systems used in the coffee industry.

![CoffeeInspection](./imgs/coffee_inspection.png)

---

## 📌 Project Overview

Manual inspection of coffee beans is time-consuming, subjective, and difficult to scale.  
This project explores how **deep learning image classification models** can be used to:

- Analyze images of green coffee beans
- Detect the presence of defects
- Classify defect types automatically

The system can be extended to real-world applications such as:
- Coffee export quality grading
- Automated inspection pipelines
- Web-based inspection tools
- Industrial quality control systems

---

## 🧠 Defect Classes

The dataset contains **17 defect categories**:

1. Broken  
2. Cut  
3. Dry Cherry  
4. Fade  
5. Floater  
6. Full Black  
7. Full Sour  
8. Fungus Damage  
9. Husk  
10. Immature  
11. Parchment  
12. Partial Black  
13. Partial Sour  
14. Severe Insect Damage  
15. Shell  
16. Slight Insect Damage  
17. Withered  

---

## 🗂 Dataset

- Image resolution: **500 × 500 pixels**
- Coffee type: **Arabica green beans**
- Dataset source: Academic research dataset

The dataset represents real defect patterns observed during coffee processing and export inspection.

### Citation

If you use this dataset, please cite the original paper:

'''
https://doi.org/10.1016/j.atech.2024.100680
'''

Acknowledgment:  
This dataset was supported by Mae Fah Luang University under the National Science, Research, and Innovation Fund (NSRF) 2023, grant no. 662A03049.

---

## 🧪 Project Architecture

### Option 1 — Single Model Pipeline
- Input image
- CNN-based classifier
- Output: one of 17 defect classes

### Option 2 — Two-Stage Inspection Pipeline (optional extension)
1. **Defect Detection Model**
   - Detects whether a bean is defective or not

2. **Defect Classification Model**
   - Classifies the detected defect into one of 17 categories

This architecture closely resembles real industrial inspection systems.

---

## 🧰 Technologies Used

- Python
- PyTorch / TensorFlow
- OpenCV
- NumPy
- Matplotlib
- Scikit-learn
- CNN architectures (ResNet, EfficientNet, etc.)

---

## 📊 Evaluation Metrics

- Accuracy
- Precision / Recall
- F1-score
- Confusion Matrix
- Class-wise performance analysis

---

## 🚀 Future Improvements

- Object detection (YOLO / Faster R-CNN) for multiple beans per image
- Defect severity estimation
- Model explainability (Grad-CAM)
- Real-time inference
- Web application deployment
- Mobile inference optimization

---

## 📁 Repository Structure (example)

'''
coffee-bean-defect-detection/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── eda.ipynb
│   └── training.ipynb
│
├── src/
│   ├── dataset.py
│   ├── model.py
│   ├── train.py
│   └── evaluate.py
│
├── models/
│   └── trained_models/
│
├── requirements.txt
└── README.md
'''