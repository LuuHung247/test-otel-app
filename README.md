# Test OpenTelemetry App

Spring Boot application để test logging với OpenTelemetry, đẩy logs lên Grafana qua Loki.

## Cấu trúc Project

```
test-otel-app/
├── src/
│   └── main/
│       ├── java/com/example/testotel/
│       │   ├── TestOtelApplication.java          # Main application
│       │   └── controller/
│       │       └── LogTestController.java        # REST endpoints để generate logs
│       └── resources/
│           └── application.yml                   # Spring Boot configuration
├── k8s/
│   ├── deployment.yaml                          # K8s Deployment
│   ├── service.yaml                             # K8s Service
│   └── kustomization.yaml                       # Kustomize config
├── Dockerfile                                   # Multi-stage Docker build
├── pom.xml                                      # Maven dependencies
└── README.md
```

## API Endpoints

### 1. Hello Endpoint
```bash
GET /api/hello
```
Trả về message đơn giản và log INFO level.

### 2. Generate All Log Levels
```bash
GET /api/logs/all
```
Generate logs ở tất cả các levels: TRACE, DEBUG, INFO, WARN, ERROR.

### 3. Generate Random Log
```bash
GET /api/logs/random
```
Generate một log entry ngẫu nhiên với level ngẫu nhiên.

### 4. Custom Log
```bash
POST /api/logs/custom?level=INFO&message=Your+message+here
```
Tạo log với level và message tùy chỉnh.

Levels hỗ trợ: TRACE, DEBUG, INFO, WARN, ERROR

### 5. Simulate Error
```bash
GET /api/simulate/error
```
Tạo exception và log error với stack trace.

### 6. Simulate Traffic
```bash
GET /api/simulate/traffic?count=100
```
Generate nhiều log entries để simulate traffic (mặc định 10).

### 7. Health Check
```bash
GET /actuator/health
```
Spring Boot actuator health endpoint.

## Build và Deploy

### 1. Build Docker Image

```bash
cd test-otel-app

# Build image
docker build -t test-otel-app:1.0.0 .

# Nếu dùng Minikube, load image vào Minikube
minikube image load test-otel-app:1.0.0

# Hoặc push lên registry của bạn
docker tag test-otel-app:1.0.0 your-registry/test-otel-app:1.0.0
docker push your-registry/test-otel-app:1.0.0
```

### 2. Deploy lên K8s

```bash
# Deploy using kubectl
kubectl apply -k k8s/

# Hoặc deploy từng file
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 3. Kiểm tra Deployment

```bash
# Xem pods
kubectl get pods -n monitoring -l app=test-otel-app

# Xem logs của pod
kubectl logs -n monitoring -l app=test-otel-app -f

# Xem service
kubectl get svc -n monitoring test-otel-app
```

### 4. Test Application

```bash
# Port forward để test local
kubectl port-forward -n monitoring svc/test-otel-app 8080:8080

# Test các endpoints
curl http://localhost:8080/api/hello
curl http://localhost:8080/api/logs/all
curl http://localhost:8080/api/logs/random
curl -X POST "http://localhost:8080/api/logs/custom?level=INFO&message=Test+message"
curl http://localhost:8080/api/simulate/error
curl http://localhost:8080/api/simulate/traffic?count=50
```

### 5. Xem Logs trong Grafana

1. Truy cập Grafana của bạn
2. Vào **Explore** 
3. Chọn data source **Loki**
4. Query logs:
   ```
   {service_name="test-otel-app"}
   ```
5. Filter theo log level:
   ```
   {service_name="test-otel-app"} |= "ERROR"
   {service_name="test-otel-app"} |= "WARN"
   ```

## OpenTelemetry Configuration

App này sử dụng OpenTelemetry Java Agent để tự động instrument. Configuration được set qua environment variables trong deployment.yaml:

- **OTEL_SERVICE_NAME**: Tên service trong traces/logs
- **OTEL_EXPORTER_OTLP_ENDPOINT**: Endpoint của OpenTelemetry Collector
- **OTEL_LOGS_EXPORTER**: Export logs qua OTLP protocol
- **OTEL_METRICS_EXPORTER**: Export metrics qua OTLP
- **OTEL_TRACES_EXPORTER**: Export traces qua OTLP

## Troubleshooting

### Logs không xuất hiện trong Grafana

1. Kiểm tra pod đang chạy:
   ```bash
   kubectl get pods -n monitoring -l app=test-otel-app
   ```

2. Xem logs của pod:
   ```bash
   kubectl logs -n monitoring -l app=test-otel-app
   ```

3. Kiểm tra OpenTelemetry Collector:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=opentelemetry-collector
   ```

4. Kiểm tra Loki:
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=loki
   ```

5. Verify OTLP endpoint:
   ```bash
   kubectl get svc -n monitoring | grep otel
   ```

### Pod không start được

1. Describe pod để xem lỗi:
   ```bash
   kubectl describe pod -n monitoring -l app=test-otel-app
   ```

2. Kiểm tra image có tồn tại:
   ```bash
   # Nếu dùng Minikube
   minikube image ls | grep test-otel-app
   ```

## Test Flow Hoàn Chỉnh

```bash
# 1. Build và load image
docker build -t test-otel-app:1.0.0 .
minikube image load test-otel-app:1.0.0

# 2. Deploy
kubectl apply -k k8s/

# 3. Đợi pod ready
kubectl wait --for=condition=ready pod -l app=test-otel-app -n monitoring --timeout=120s

# 4. Port forward
kubectl port-forward -n monitoring svc/test-otel-app 8080:8080 &

# 5. Generate logs
curl http://localhost:8080/api/logs/all
curl http://localhost:8080/api/simulate/traffic?count=100

# 6. Kiểm tra trong Grafana
# Query: {service_name="test-otel-app"}
```

## Clean Up

```bash
# Xóa deployment
kubectl delete -k k8s/

# Hoặc
kubectl delete deployment test-otel-app -n monitoring
kubectl delete service test-otel-app -n monitoring
```
