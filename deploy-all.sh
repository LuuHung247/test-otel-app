#!/bin/bash

set -e

echo "=================================================="
echo "Deploying Complete Observability Stack + Test App"
echo "=================================================="
echo ""

# Step 1: Deploy monitoring stack first
echo "STEP 1: Deploying Monitoring Stack"
echo "-----------------------------------"
./deploy-monitoring.sh

echo ""
echo "Waiting for monitoring components to be ready..."
echo "This may take a few minutes..."
sleep 30

# Check if Loki is ready
echo "Checking Loki status..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=loki -n monitoring --timeout=300s || echo "Warning: Loki not ready yet, continuing..."

# Check if Prometheus is ready
echo "Checking Prometheus status..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s || echo "Warning: Prometheus not ready yet, continuing..."

# Check if OTEL Collector is ready
echo "Checking OpenTelemetry Collector status..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=opentelemetry-collector -n monitoring --timeout=300s || echo "Warning: OTEL Collector not ready yet, continuing..."

echo ""
echo "STEP 2: Building and Deploying Test Application"
echo "------------------------------------------------"
./deploy-app.sh

echo ""
echo "=================================================="
echo "Complete Stack Deployed Successfully!"
echo "=================================================="
echo ""
echo "Monitoring Stack:"
echo "  - Grafana: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "    Username: admin, Password: admin"
echo "  - Prometheus: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo "  - Loki (bloom): kubectl port-forward -n monitoring svc/grafana-loki-bloom 3100:3100"
echo ""
echo "Test Application:"
echo "  - App: kubectl port-forward -n monitoring svc/test-otel-app 8080:8080"
echo "  - Run tests: ./test-endpoints.sh"
echo ""
echo "View all pods:"
echo "  kubectl get pods -n monitoring"
echo ""
echo "View all services:"
echo "  kubectl get svc -n monitoring"
echo ""
