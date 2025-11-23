#!/bin/bash

# Build Docker images for Kubernetes deployment

set -e

echo "🔨 Building Docker images..."

# Build backend
echo "Building backend image..."
cd backend
docker build -t node-backend:latest .
cd ..

# Build frontend
echo "Building frontend image..."
cd frontend
docker build -t react-frontend:latest .
cd ..

echo "✅ Images built successfully!"
echo ""
echo "📦 Images:"
echo "   - node-backend:latest"
echo "   - react-frontend:latest"
echo ""
echo "💡 For minikube, load images with:"
echo "   minikube image load node-backend:latest"
echo "   minikube image load react-frontend:latest"
echo ""
echo "💡 For other clusters, push to registry:"
echo "   docker tag node-backend:latest <registry>/node-backend:latest"
echo "   docker tag react-frontend:latest <registry>/react-frontend:latest"
echo "   docker push <registry>/node-backend:latest"
echo "   docker push <registry>/react-frontend:latest"

