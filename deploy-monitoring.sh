#!/bin/bash

set -e

echo "===================================="
echo "Deploying Monitoring Stack"
echo "===================================="
echo ""

# Deploy monitoring stack
echo "1. Deploying monitoring components..."
kubectl apply -k k8s/monitoring/

echo ""
echo "2. Waiting for namespace..."
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/monitoring --timeout=60s

echo ""
echo "3. Monitoring stack deployment initiated!"
echo ""
echo "Components being deployed:"
echo "  - Grafana Loki (bloom)"
echo "  - Prometheus + Grafana"
echo "  - Tempo"
echo "  - OpenTelemetry Collector"
echo ""
echo "Check deployment status:"
echo "  kubectl get pods -n monitoring"
echo ""
echo "Access Grafana (once ready):"
echo "  minikube service kube-prometheus-stack-grafana -n monitoring"
echo "  Or port-forward: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "  Username: admin"
echo "  Password: admin"
echo ""
