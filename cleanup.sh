#!/bin/bash

set -e

echo "===================================="
echo "Cleaning Up Test Environment"
echo "===================================="
echo ""

read -p "This will delete the entire monitoring namespace and all resources. Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleanup cancelled."
    exit 1
fi

echo ""
echo "Deleting all resources..."

# Delete using kustomize
echo "1. Deleting application..."
kubectl delete -k k8s/app/ --ignore-not-found=true

echo ""
echo "2. Deleting monitoring stack..."
kubectl delete -k k8s/monitoring/ --ignore-not-found=true

echo ""
echo "3. Deleting namespace (if still exists)..."
kubectl delete namespace monitoring --ignore-not-found=true

echo ""
echo "===================================="
echo "Cleanup completed!"
echo "===================================="
echo ""
echo "All resources have been removed."
echo ""
