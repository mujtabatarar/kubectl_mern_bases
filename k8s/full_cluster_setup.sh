#!/bin/bash

# ----------------------------
# Variables
# ----------------------------
CONTROL_PLANE_IP="192.168.56.101"
POD_CIDR="10.244.0.0/16"
CILIUM_VERSION="1.15.3"

# Nodes for RBAC
NODES=("alma-two" "alma-three" "alma-four" "alma-five")

# ----------------------------
# Step 1: Cleanup old Cilium
# ----------------------------
echo "Cleaning up old Cilium pods..."
kubectl delete daemonset cilium -n kube-system --ignore-not-found
kubectl delete deployment cilium-operator -n kube-system --ignore-not-found

# ----------------------------
# Step 2: RBAC Fix
# ----------------------------
echo "Applying RBAC permissions for all nodes..."
for node in "${NODES[@]}"; do
  kubectl create clusterrolebinding cilium-admin-$node \
    --clusterrole=cluster-admin \
    --user=system:node:$node \
    --dry-run=client -o yaml | kubectl apply -f -
done

# ----------------------------
# Step 3: Install Cilium fresh
# ----------------------------
echo "Installing Cilium..."
curl -L https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz | tar xz
sudo mv cilium /usr/local/bin

cilium install --version $CILIUM_VERSION --set kubeProxyReplacement=strict

# ----------------------------
# Step 4: Wait for Cilium pods to be ready
# ----------------------------
echo "Waiting for Cilium pods to become Ready..."
cilium status --wait

# ----------------------------
# Step 5: Verify nodes and pods
# ----------------------------
echo "Verifying nodes status..."
kubectl get nodes -o wide

echo "Verifying kube-system pods..."
kubectl get pods -n kube-system -o wide

echo "Cluster setup completed!"
