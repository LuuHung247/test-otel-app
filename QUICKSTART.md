# Quick Start Guide

## Deploy Complete Observability Stack

### Fastest Way - Deploy Everything (1 Command)

```bash
cd test-otel-app
./deploy-all.sh
```

Lệnh này sẽ:
1. Deploy Grafana, Loki (bloom), Prometheus, Tempo, OpenTelemetry Collector
2. Build Spring Boot app với OpenTelemetry
3. Deploy app lên K8s
4. Tự động kết nối app với monitoring stack

⏱️ Thời gian: ~3-5 phút (tùy vào tốc độ pull images)

### Step by Step

#### 1. Deploy Monitoring Stack

```bash
./deploy-monitoring.sh
```

Đợi cho monitoring stack ready:
```bash
kubectl get pods -n monitoring -w
```

#### 2. Deploy Test Application

```bash
./deploy-app.sh
```

## Access Services

### Grafana (Xem logs, metrics, traces)

```bash
# Port forward
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Or với Minikube
minikube service kube-prometheus-stack-grafana -n monitoring
```

Open: http://localhost:3000
- Username: **admin**
- Password: **admin**

### Test Application

```bash
# Port forward
kubectl port-forward -n monitoring svc/test-otel-app 8080:8080 &

# Generate logs
./test-endpoints.sh
```

## View Logs trong Grafana

1. Mở Grafana (http://localhost:3000)
2. Login với admin/admin
3. Click **Explore** (icon la bàn bên trái)
4. Chọn data source **Loki-Bloom**
5. Chạy query:

```
{service_name="test-otel-app"}
```

6. Bạn sẽ thấy logs từ test app!

### Example Queries

```promql
# All logs
{service_name="test-otel-app"}

# Only ERROR logs
{service_name="test-otel-app"} |= "ERROR"

# Search for specific text
{service_name="test-otel-app"} |= "Simulated"

# Count errors
sum(count_over_time({service_name="test-otel-app"} |= "ERROR" [1m]))
```

## Generate Test Data

### Quick Test (All log levels)
```bash
curl http://localhost:8080/api/logs/all
```

### Generate Traffic (100 logs)
```bash
curl "http://localhost:8080/api/simulate/traffic?count=100"
```

### Simulate Error
```bash
curl "http://localhost:8080/api/simulate/error"
```

### Run All Tests
```bash
./test-endpoints.sh
```

## View Traces in Grafana

1. Explore → Select **Tempo** data source
2. Query by service name: `test-otel-app`
3. Click on traces để xem chi tiết spans

## View Metrics in Grafana

1. Explore → Select **Prometheus** data source
2. Query examples:

```promql
# HTTP request rate
rate(http_server_requests_seconds_count[5m])

# Memory usage
jvm_memory_used_bytes{service="test-otel-app"}
```

## Architecture Overview

```
Test App → OTEL Collector → Loki (bloom) → Grafana
                          → Prometheus    ↗
                          → Tempo        ↗
```

## Deployment Options

```bash
# Deploy everything
./deploy-all.sh

# Deploy only monitoring stack
./deploy-monitoring.sh

# Deploy only application
./deploy-app.sh

# Clean up everything
./cleanup.sh
```

## Check Status

```bash
# All pods
kubectl get pods -n monitoring

# All services
kubectl get svc -n monitoring

# Logs từ OTEL Collector
kubectl logs -n monitoring -l app.kubernetes.io/name=opentelemetry-collector -f

# Logs từ Loki
kubectl logs -n monitoring -l app.kubernetes.io/name=loki -f

# Logs từ test app
kubectl logs -n monitoring -l app=test-otel-app -f
```

## Troubleshooting

### Pods không ready?

```bash
kubectl describe pod <pod-name> -n monitoring
```

### Không thấy logs trong Grafana?

1. Check OTEL Collector logs:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=opentelemetry-collector --tail=50
   ```

2. Check Loki logs:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=loki --tail=50
   ```

3. Generate more test data:
   ```bash
   curl "http://localhost:8080/api/simulate/traffic?count=50"
   ```

### Image pull error?

```bash
# Rebuild và reload image
docker build -t test-otel-app:1.0.0 .
minikube image load test-otel-app:1.0.0
kubectl rollout restart deployment/test-otel-app -n monitoring
```

## What's Included

### Monitoring Stack
- ✅ **Grafana** - Visualization dashboard (port 3000)
- ✅ **Loki (bloom)** - Log aggregation with bloom filters
- ✅ **Prometheus** - Metrics collection (port 9090)
- ✅ **Tempo** - Distributed tracing
- ✅ **OpenTelemetry Collector** - Telemetry pipeline

### Test Application
- ✅ Spring Boot with OpenTelemetry auto-instrumentation
- ✅ Multiple logging endpoints for testing
- ✅ Auto-generates logs, metrics, and traces
- ✅ Health checks and actuator endpoints

## Next Steps

1. Đọc [MONITORING-GUIDE.md](MONITORING-GUIDE.md) để hiểu chi tiết architecture
2. Đọc [README.md](README.md) để xem tất cả API endpoints
3. Customize monitoring config trong `k8s/monitoring/`
4. Thêm custom dashboards trong Grafana

## Clean Up

Khi không cần nữa:

```bash
./cleanup.sh
```

Lệnh này sẽ xóa:
- Toàn bộ monitoring stack
- Test application
- Monitoring namespace
