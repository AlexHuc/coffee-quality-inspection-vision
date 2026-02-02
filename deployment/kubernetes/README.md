# Kubernetes Local Deployment for Coffee Quality Inspection

![Minikube and Kubernetes](../../imgs/minikube_and_kubernetes.png)

This documentation covers the Kubernetes deployment of the **Coffee Quality Inspection Vision Service**, which classifies 17 different types of coffee bean defects from images using trained deep learning models.

# Record of Deployment on Kubernetes

![Kubernetes Deploy](../../imgs/KubernetesDeploy.gif)

## 📋 Prerequisites

- [Docker](https://www.docker.com/) installed and running
- [minikube](https://minikube.sigs.k8s.io/docs/start/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- Python environment (for testing scripts and notebooks)

## 🚀 Deployment

### 1. Deploy to Local Kubernetes Cluster

```
# From the project root directory
./deployment/kubernetes/deploy.sh
```

The deployment script will:
- Start minikube
- Build the Docker image in minikube's environment
- Deploy the service to Kubernetes
- Wait for the pod to be ready
- Display service information
- Set up port forwarding to localhost:9696

### 2. Access the Service

```
# Get the service URL
minikube service coffee-prediction-service -n coffee-prediction --url

# Or open in browser directly
minikube service coffee-prediction-service -n coffee-prediction
```

### 3. View in Kubernetes Dashboard

```
# Open Kubernetes dashboard
minikube dashboard
```

**Important:** Select the **"coffee-prediction"** namespace to view your deployment.

## 🧪 Testing the Service

### Health Check

```
curl -X GET http://localhost:9696/health
```

**Response:**
```
{
  "service": "coffee-prediction",
  "status": "healthy",
  "timestamp": "2026-01-19 22:03:51"
}
```

### Image Prediction Endpoint

The model expects **input images** and outputs a **defect classification** for coffee beans.

The model uses **ConvNeXt Tiny** architecture trained to classify 17 defect types:
- Broken, Cut, Dry Cherry, Fade, Floater, Full Black, Full Sour
- Fungus Damange, Husk, Immature, Parchment, Partial Black
- Partial Sour, Severe Insect Damange, Shell, Slight Insect Damage, Withered

To test predictions:

1. Convert your coffee bean image to base64.
2. Send it in JSON to `/predict` endpoint.

Example JSON:

```
{
  "image": "<base64-encoded-image>"
}
```

**Response JSON:**
```
{
  "class_id": 1,
  "class_name": "broken",
  "confidence": 0.8543
}
```

- `class_id` → Defect class ID (0-16)
- `class_name` → Defect class name
- `confidence` → Prediction confidence score

### Test via Jupyter Notebook

```
# Navigate to deployment directory
cd deployment/flask

# Open testing notebook
jupyter notebook predict_test.ipynb
```

This notebook demonstrates sending an image to the API and visualizing the predicted mask.

## 📁 Deployment Structure

```
deployment/kubernetes/
├── deploy.sh              # Automated deployment script
├── deployment.yaml        # Kubernetes manifests (namespace, configmap, deployment, service)
└── README.md              # This file
```

## 🛠️ Useful Commands

```
# Check deployment status
kubectl get all -n coffee-prediction

# View pod logs
kubectl logs -l app=coffee-prediction -n coffee-prediction

# View detailed pod information
kubectl describe pod -l app=coffee-prediction -n coffee-prediction

# Delete deployment
kubectl delete -f deployment/kubernetes/deployment.yaml

# Stop minikube
minikube stop

# Start minikube again
minikube start

# Kill port forwarding
pkill -f "kubectl port-forward.*9696"
```

## 🔧 Service Configuration

- **Image:** `coffee-predictor:latest` (built locally in minikube)
- **Port:** Service runs on port 80, forwards to container port 9696
- **NodePort:** 30081 for external access
- **Namespace:** `coffee-prediction`
- **Health Checks:** Readiness and liveness probes on `/health`
- **Resources:**
  - CPU: 250m request, 500m limit
  - Memory: 512Mi request, 1Gi limit

## 📊 Architecture

The deployment creates:

1. **Namespace:** `coffee-prediction` for resource isolation
2. **ConfigMap:** Environment variables (e.g., model paths)
3. **Deployment:** Flask application container with auto-restart
4. **Service:** NodePort for external access
5. **Pod:** Runs the prediction service with the deep learning models

### Kubernetes Resource Flow

```
┌─────────────────────────────────────┐
│   Kubernetes Cluster (minikube)     │
├─────────────────────────────────────┤
│  Namespace: coffee-prediction       │
│                                     │
│  ┌─ Deployment ─────────────────┐   │
│  │ coffee-prediction-deployment │   │
│  │ ┌─ Pod ──────────────────┐   │   │
│  │ │ Flask App (9696)       │   │   │
│  │ │ Deep Learning Models   │   │   │
│  │ │ Health Checks          │   │   │
│  │ └────────────────────────┘   │   │
│  └───────────────┬──────────────┘   │
│                  │                  │
│  ┌───────────────┴────────────────┐ │
│  │ Service: NodePort (30081)      │ │
│  │ Port Forwarding (9696)         │ │
│  └────────────────────────────────┘ │
└──────────> localhost:9696
```

## 🔄 Deployment Workflow

1. **Build Phase**
```
docker build -t coffee-predictor:latest -f deployment/flask/Dockerfile .
```

2. **Deploy Phase**
```
kubectl apply -f deployment/kubernetes/deployment.yaml
```

3. **Ready Phase**
- Pod ready when health check passes

4. **Port Forward Phase**
```
kubectl port-forward service/coffee-prediction-service 9696:80
```

5. **Access Phase**
- Service available at `http://localhost:9696`

## 🚨 Troubleshooting

- **Pod not running:** `kubectl get pods -n coffee-prediction`
- **View logs:** `kubectl logs -l app=coffee-prediction -n coffee-prediction`
- **Port forwarding issues:** `pkill -f "kubectl port-forward.*9696"`
- **Models not loading:** Ensure `.pt` files exist in `models/` before building

## 🧹 Cleanup

```
# Delete namespace and all resources
kubectl delete namespace coffee-prediction

# Stop minikube
minikube stop

# Delete minikube cluster
minikube delete
```