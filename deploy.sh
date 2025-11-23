#!/bin/bash

# Simple deployment script for Kubernetes

set -e

NAMESPACE="sample-app"

echo "🚀 Starting deployment..."

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Deploy MySQL
echo "🗄️  Deploying MySQL..."
kubectl apply -f k8s/mysql-configmap.yaml
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL
echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=120s || true

# Deploy Backend
echo "🔧 Deploying Backend..."
kubectl apply -f k8s/backend-deployment.yaml

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f k8s/frontend-deployment.yaml

# Show status
echo "✅ Deployment complete!"
echo ""
echo "📊 Current status:"
kubectl get all -n $NAMESPACE

echo ""
echo "🌐 To access the frontend:"
echo "   kubectl port-forward -n $NAMESPACE svc/frontend 4000:80"
echo ""
echo "   Then open http://localhost:4000 in your browser"

