#!/bin/bash

set -e

IMAGE_NAME="test-otel-app"
IMAGE_TAG="1.0.0"
NAMESPACE="monitoring"

echo "=================================="
echo "Building and Deploying $IMAGE_NAME"
echo "=================================="

# Build Docker image
echo "1. Building Docker image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# Check if using Minikube
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    echo "2. Loading image to Minikube..."
    minikube image load $IMAGE_NAME:$IMAGE_TAG
else
    echo "2. Minikube not detected, skipping image load..."
    echo "   If using a registry, push image manually:"
    echo "   docker push your-registry/$IMAGE_NAME:$IMAGE_TAG"
fi

# Deploy to Kubernetes
echo "3. Deploying application to Kubernetes..."
kubectl apply -k k8s/app/

# Wait for deployment
echo "4. Waiting for deployment to be ready..."
kubectl wait --for=condition=ready pod -l app=$IMAGE_NAME -n $NAMESPACE --timeout=120s || true

# Show status
echo "5. Deployment status:"
kubectl get pods -n $NAMESPACE -l app=$IMAGE_NAME
kubectl get svc -n $NAMESPACE $IMAGE_NAME

echo ""
echo "=================================="
echo "Deployment completed!"
echo "=================================="
echo ""
echo "To test the application:"
echo "  kubectl port-forward -n $NAMESPACE svc/$IMAGE_NAME 8080:8080"
echo ""
echo "Then visit:"
echo "  curl http://localhost:8080/api/hello"
echo "  curl http://localhost:8080/api/logs/all"
echo "  curl http://localhost:8080/api/simulate/traffic?count=50"
echo ""
echo "Or run test script:"
echo "  ./test-endpoints.sh"
echo ""
