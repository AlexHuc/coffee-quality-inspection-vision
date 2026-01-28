#!/bin/bash
# Deployment script for Coffee Defect Prediction API on Minikube

echo "🚀 Deploying Coffee Defect Prediction API on Minikube"

# Check if running from project root
if [ ! -d "deployment" ]; then
    echo "❌ Run this from the project root directory"
    exit 1
fi

# Minikube resource configuration
MINIKUBE_CPUS=${MINIKUBE_CPUS:-2}
MINIKUBE_MEMORY=${MINIKUBE_MEMORY:-4096}

# Start minikube
echo "📦 Starting minikube..."
minikube start --driver=docker --cpus=$MINIKUBE_CPUS --memory=$MINIKUBE_MEMORY

# Use Minikube Docker environment
echo "🐳 Configuring Docker to use Minikube environment..."
eval $(minikube docker-env)

# Build Docker image inside minikube
echo "🐳 Building Docker image in Minikube..."
docker build -t coffee-predictor:latest -f deployment/flask/Dockerfile .

# Apply Kubernetes manifests
echo "☸️ Deploying to Kubernetes..."
kubectl apply -f ./deployment/kubernetes/deployment.yaml

# Wait for pod to be ready
echo "⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod -l app=coffee-prediction -n coffee-prediction --timeout=180s

# Show pod and service status
echo ""
echo "📊 Status:"
kubectl get pods -n coffee-prediction
kubectl get svc -n coffee-prediction

# Setup port-forwarding
echo ""
echo "🌐 Setting up port forwarding to localhost:9696..."

# Kill any existing port-forward on 9696
if lsof -i:9696 >/dev/null 2>&1; then
    echo "⚠️ Port 9696 already in use, killing existing process..."
    pkill -f "kubectl port-forward.*9696"
    sleep 1
fi

# Start port-forwarding in background
kubectl port-forward service/coffee-prediction-service 9696:80 -n coffee-prediction &
PORT_FORWARD_PID=$!

sleep 2  # allow forwarding to start

echo "✅ Service available at: http://localhost:9696"
echo ""
echo "📊 To open dashboard:"
echo "   minikube dashboard"
echo "   (Select 'coffee-prediction' namespace)"
echo ""
echo "🧪 To test the API:"
echo "   curl -X GET http://localhost:9696/health"
echo "   curl -X POST -F 'file=@data/processed/Broken/Broken_05.jpg' http://localhost:9696/predict_image"
echo ""
echo "📝 Port forwarding is running in background (PID: $PORT_FORWARD_PID)"
echo "   To stop: kill $PORT_FORWARD_PID"
echo "   Keep this terminal open while using the service"
