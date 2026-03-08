#!/bin/bash
set -e

echo "=== Deploying Zero Trust Demo Environment ==="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed"
    exit 1
fi

# Check if tunnel-token secret exists
echo "Checking for tunnel token..."
if ! sudo kubectl get secret tunnel-token -n demo &> /dev/null; then
    echo ""
    echo "Warning: tunnel-token secret not found"
    echo "The secret will be created from k8s/cloudflared/secret.yaml"
    echo "Make sure you have created k8s/cloudflared/secret.yaml with your tunnel token"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Deploy using kustomize
echo "Deploying resources..."
sudo kubectl apply -k k8s/

# Wait for deployments to be ready
echo ""
echo "Waiting for deployments to be ready..."
sudo kubectl wait --for=condition=available --timeout=300s \
  deployment/web \
  deployment/ssh \
  deployment/rdp \
  deployment/smb \
  deployment/vnc \
  deployment/cloudflared \
  -n demo

# Show status
echo ""
echo "=== Deployment Status ==="
sudo kubectl get pods -n demo
echo ""
sudo kubectl get svc -n demo

echo ""
echo "=== Deployment complete ==="
