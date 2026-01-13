# Project Structure

Complete overview of test-otel-app project.

## Quick Navigation

- **QUICKSTART.md** - Quick start guide
- **MONITORING-GUIDE.md** - Detailed monitoring docs  
- **README.md** - API documentation
- **PROJECT-STRUCTURE.md** - This file

## Directory Structure

```
test-otel-app/
├── src/                              Spring Boot source code
├── k8s/
│   ├── monitoring/                   Loki, Grafana, Prometheus, Tempo
│   └── app/                          Application manifests
├── deploy-all.sh                     Deploy complete stack
├── deploy-monitoring.sh              Deploy monitoring only
├── deploy-app.sh                     Deploy app only
└── cleanup.sh                        Remove everything
```

## Monitoring Components

- **Loki (bloom)** - Log aggregation
- **Grafana** - Visualization (admin/admin)
- **Prometheus** - Metrics collection
- **Tempo** - Distributed tracing
- **OpenTelemetry** - Telemetry pipeline

## Quick Start

```bash
./deploy-all.sh
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Open http://localhost:3000 (admin/admin)
