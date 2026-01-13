# Monitoring Stack Guide

Guide để deploy và sử dụng complete observability stack với Grafana, Loki (bloom), Prometheus, và Tempo.

## Cấu trúc Project

```
test-otel-app/
├── k8s/
│   ├── monitoring/               # Monitoring stack
│   │   ├── namespace.yaml
│   │   ├── grafana-loki-bloom.yaml    # Loki with bloom filters
│   │   ├── kube-prometheus-stack.yaml # Prometheus + Grafana
│   │   ├── grafana-tempo.yaml         # Tempo for traces
│   │   ├── opentelemetry.yaml         # OTEL Collector
│   │   └── kustomization.yaml
│   ├── app/                      # Test application
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── kustomization.yaml        # Root kustomization
├── deploy-monitoring.sh          # Deploy only monitoring
├── deploy-app.sh                 # Deploy only app
├── deploy-all.sh                 # Deploy everything
├── deploy.sh                     # Wrapper script
├── cleanup.sh                    # Clean up everything
└── test-endpoints.sh             # Test app endpoints
```

## Components

### Monitoring Stack

1. **Grafana Loki (bloom)** - Log aggregation với bloom filters
   - Port: 3100
   - OTLP endpoint: `http://grafana-loki-bloom:3100/otlp`
   - MinIO backend for storage

2. **Prometheus + Grafana** - Metrics và visualization
   - Grafana: port 80 (NodePort 30080)
   - Prometheus: port 9090 (NodePort 30090)
   - Default credentials: admin/admin
   - Pre-configured data sources:
     - Loki-Bloom
     - Tempo
     - Prometheus

3. **Tempo** - Distributed tracing
   - Port: 3100 (HTTP), 4317 (gRPC), 4318 (HTTP)
   - Storage: MinIO backend (shared with Loki)

4. **OpenTelemetry Collector** - Telemetry data collection
   - Receives: OTLP (gRPC: 4317, HTTP: 4318)
   - Exports to:
     - Loki (logs)
     - Prometheus (metrics)
     - Tempo (traces)

### Test Application

Spring Boot app với OpenTelemetry instrumentation:
- Auto-instrumentation via Java Agent
- Generates logs, metrics, and traces
- Multiple endpoints for testing

## Deployment

### Option 1: Deploy Everything (Recommended)

```bash
cd test-otel-app

# Deploy complete stack
./deploy-all.sh
```

Script này sẽ:
1. Deploy monitoring stack (Loki, Prometheus, Grafana, Tempo, OTEL)
2. Đợi monitoring components ready
3. Build Docker image
4. Deploy test application

### Option 2: Deploy Step by Step

```bash
# 1. Deploy monitoring stack first
./deploy-monitoring.sh

# 2. Wait for components to be ready (check with kubectl)
kubectl get pods -n monitoring

# 3. Deploy application
./deploy-app.sh
```

### Option 3: Deploy Separately

```bash
# Deploy only monitoring
./deploy-monitoring.sh

# Or deploy only app (requires monitoring to be running)
./deploy-app.sh
```

## Accessing Services

### Grafana

**Option 1: NodePort (if using Minikube)**
```bash
minikube service kube-prometheus-stack-grafana -n monitoring
```

**Option 2: Port Forward**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Then open: http://localhost:3000
- Username: `admin`
- Password: `admin`

### Prometheus

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

Open: http://localhost:9090

### Test Application

```bash
kubectl port-forward -n monitoring svc/test-otel-app 8080:8080
```

Test endpoints:
```bash
./test-endpoints.sh
```

Or manually:
```bash
curl http://localhost:8080/api/hello
curl http://localhost:8080/api/logs/all
curl http://localhost:8080/api/simulate/traffic?count=100
```

## Viewing Logs in Grafana

1. Open Grafana (http://localhost:3000)
2. Login with admin/admin
3. Go to **Explore** (compass icon)
4. Select **Loki-Bloom** data source
5. Run queries:

```promql
# All logs from test app
{service_name="test-otel-app"}

# Filter by log level
{service_name="test-otel-app"} |= "ERROR"
{service_name="test-otel-app"} |= "WARN"
{service_name="test-otel-app"} |= "INFO"

# Search for text
{service_name="test-otel-app"} |= "Simulated"

# Count errors per minute
sum(count_over_time({service_name="test-otel-app"} |= "ERROR" [1m]))
```

## Viewing Traces in Grafana

1. Go to **Explore**
2. Select **Tempo** data source
3. Query traces from test app
4. Click on traces to see spans and details

## Viewing Metrics in Grafana

1. Go to **Explore**
2. Select **Prometheus** data source
3. Query metrics:

```promql
# HTTP request rate
rate(http_server_requests_seconds_count{service="test-otel-app"}[5m])

# HTTP request duration
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket{service="test-otel-app"}[5m]))

# JVM memory usage
jvm_memory_used_bytes{service="test-otel-app"}
```

## Testing the Complete Flow

1. **Deploy everything**:
   ```bash
   ./deploy-all.sh
   ```

2. **Wait for all pods to be ready**:
   ```bash
   kubectl get pods -n monitoring -w
   ```

3. **Port forward Grafana**:
   ```bash
   kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
   ```

4. **Port forward test app**:
   ```bash
   kubectl port-forward -n monitoring svc/test-otel-app 8080:8080 &
   ```

5. **Generate logs**:
   ```bash
   ./test-endpoints.sh
   ```

6. **View in Grafana**:
   - Open http://localhost:3000
   - Login: admin/admin
   - Go to Explore → Loki-Bloom
   - Query: `{service_name="test-otel-app"}`

## Architecture

```
┌─────────────────┐
│  Test OTEL App  │
│  (Spring Boot)  │
└────────┬────────┘
         │ OTLP (logs, metrics, traces)
         ↓
┌─────────────────────────┐
│ OpenTelemetry Collector │
└────┬──────┬──────┬──────┘
     │      │      │
     ↓      ↓      ↓
┌────────┐ ┌──────────┐ ┌───────┐
│  Loki  │ │Prometheus│ │ Tempo │
│ (bloom)│ │          │ │       │
└───┬────┘ └────┬─────┘ └───┬───┘
    │           │            │
    └───────────┴────────────┘
                │
         ┌──────▼──────┐
         │   Grafana   │
         │ (Dashboard) │
         └─────────────┘
```

## Storage

- **Loki**: MinIO (S3-compatible) storage
  - Bucket: loki
  - Credentials: root-user/supersecretpassword
  - Endpoint: grafana-loki-bloom-minio:9000

- **Tempo**: Shared MinIO storage
  - Bucket: tempo
  - Same credentials and endpoint

- **Prometheus**: PVC (5Gi)
  - Retention: 7 days

## Cleanup

To remove everything:

```bash
./cleanup.sh
```

This will:
- Delete all application resources
- Delete all monitoring resources
- Delete the monitoring namespace

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl get pods -n monitoring

# Describe pod to see errors
kubectl describe pod <pod-name> -n monitoring

# Check logs
kubectl logs -n monitoring <pod-name>
```

### Logs not appearing in Grafana

1. Check OTEL Collector:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=opentelemetry-collector
   ```

2. Check Loki:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=loki
   ```

3. Verify service endpoints:
   ```bash
   kubectl get svc -n monitoring
   ```

4. Test OTLP endpoint:
   ```bash
   kubectl run -it --rm curl --image=curlimages/curl --restart=Never -- \
     curl -v http://test-app-otel-opentelemetry-collector.monitoring.svc.cluster.local:4318/v1/logs
   ```

### Image pull errors

If using Minikube:
```bash
cd test-otel-app
docker build -t test-otel-app:1.0.0 .
minikube image load test-otel-app:1.0.0
kubectl rollout restart deployment/test-otel-app -n monitoring
```

### MinIO connection issues

Check MinIO pods:
```bash
kubectl get pods -n monitoring | grep minio
kubectl logs -n monitoring <minio-pod-name>
```

## Advanced: Customization

### Change Loki to use different storage

Edit `k8s/monitoring/grafana-loki-bloom.yaml`:
```yaml
storage:
  type: filesystem  # or s3, gcs, azure
```

### Scale replicas

```bash
# Scale OTEL Collector
kubectl scale deployment test-app-otel-opentelemetry-collector -n monitoring --replicas=2

# Scale Prometheus
kubectl scale statefulset prometheus-kube-prometheus-stack-prometheus -n monitoring --replicas=2
```

### Change retention

Edit `k8s/monitoring/kube-prometheus-stack.yaml`:
```yaml
prometheus:
  prometheusSpec:
    retention: 30d  # Change from 7d to 30d
```

## Resources

- [Grafana Loki Documentation](https://grafana.com/docs/loki/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Tempo Documentation](https://grafana.com/docs/tempo/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
