# Quick Start Guide

## Cách nhanh nhất để chạy app

### 1. Build và Deploy (1 lệnh)

```bash
cd test-otel-app
./deploy.sh
```

Script này sẽ:
- Build Docker image
- Load vào Minikube (nếu đang dùng)
- Deploy lên K8s cluster
- Đợi pod ready

### 2. Test Application

```bash
# Port forward để test
kubectl port-forward -n monitoring svc/test-otel-app 8080:8080 &

# Run test script
./test-endpoints.sh
```

### 3. Xem Logs trong Grafana

1. Truy cập Grafana UI
2. Vào **Explore**
3. Chọn **Loki** data source
4. Chạy query:
   ```
   {service_name="test-otel-app"}
   ```

### 4. Generate nhiều logs để test

```bash
# Generate 100 log entries
curl "http://localhost:8080/api/simulate/traffic?count=100"

# Generate error logs
curl "http://localhost:8080/api/simulate/error"

# Generate all log levels
curl "http://localhost:8080/api/logs/all"
```

## Test với Loki Bloom

Nếu bạn đã deploy `grafana-loki-bloom`, bạn cần update deployment để point đến Loki mới:

```bash
# Edit deployment
kubectl edit deployment test-otel-app -n monitoring

# Tìm và thay đổi OTEL_EXPORTER_OTLP_ENDPOINT
# Hoặc dùng lệnh patch:
kubectl set env deployment/test-otel-app \
  -n monitoring \
  OTEL_EXPORTER_OTLP_ENDPOINT=http://open-telemetry-opentelemetry-collector.monitoring.svc.cluster.local:4318
```

Sau đó check trong Grafana với Loki bloom data source.

## Useful Commands

```bash
# Xem pod logs
kubectl logs -n monitoring -l app=test-otel-app -f

# Xem pod status
kubectl get pods -n monitoring -l app=test-otel-app

# Restart deployment
kubectl rollout restart deployment/test-otel-app -n monitoring

# Delete deployment
kubectl delete -k k8s/

# Scale replicas
kubectl scale deployment/test-otel-app -n monitoring --replicas=2
```

## Grafana Queries Examples

```promql
# All logs from app
{service_name="test-otel-app"}

# Only ERROR logs
{service_name="test-otel-app"} |= "ERROR"

# Only WARN logs
{service_name="test-otel-app"} |= "WARN"

# Search for specific text
{service_name="test-otel-app"} |= "Simulated"

# Last 5 minutes
{service_name="test-otel-app"} [5m]

# Count errors per minute
sum(count_over_time({service_name="test-otel-app"} |= "ERROR" [1m]))
```

## Troubleshooting

**Pod không start:**
```bash
kubectl describe pod -n monitoring -l app=test-otel-app
```

**Không thấy logs trong Grafana:**
```bash
# Check OTEL collector
kubectl logs -n monitoring -l app.kubernetes.io/name=opentelemetry-collector --tail=100

# Check Loki
kubectl logs -n monitoring -l app.kubernetes.io/name=loki --tail=100

# Verify service endpoints
kubectl get svc -n monitoring
```

**Image pull error:**
```bash
# Rebuild và load lại image
docker build -t test-otel-app:1.0.0 .
minikube image load test-otel-app:1.0.0

# Restart deployment
kubectl rollout restart deployment/test-otel-app -n monitoring
```
