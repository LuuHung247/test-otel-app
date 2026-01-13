# Deployment Fix Applied

## Problem
Kustomize error: "ID conflict" với duplicate Secret resources:
- `grafana-repo` xuất hiện trong cả `grafana-loki-bloom.yaml` và `grafana-tempo.yaml`
- `prometheus-community-repo` trong `kube-prometheus-stack.yaml`
- `open-telemetry-repo` trong `opentelemetry.yaml`

## Solution
✅ Đã tách tất cả Helm repository Secrets vào file riêng [k8s/monitoring/repos.yaml](k8s/monitoring/repos.yaml)

## Changes Made

1. **Tạo file mới**: [k8s/monitoring/repos.yaml](k8s/monitoring/repos.yaml)
   - Contains all 3 Helm repository secrets
   - Single source of truth

2. **Removed duplicate Secrets từ**:
   - [k8s/monitoring/grafana-loki-bloom.yaml](k8s/monitoring/grafana-loki-bloom.yaml)
   - [k8s/monitoring/grafana-tempo.yaml](k8s/monitoring/grafana-tempo.yaml)
   - [k8s/monitoring/kube-prometheus-stack.yaml](k8s/monitoring/kube-prometheus-stack.yaml)
   - [k8s/monitoring/opentelemetry.yaml](k8s/monitoring/opentelemetry.yaml)

3. **Updated**: [k8s/monitoring/kustomization.yaml](k8s/monitoring/kustomization.yaml)
   - Added `repos.yaml` to resources list

## Verification

```bash
# Test kustomize build
kubectl kustomize k8s/
```

✅ Build successful!

## Deploy Now

```bash
# Deploy monitoring stack
./deploy-monitoring.sh

# Or deploy everything
./deploy-all.sh
```

## What Changed in Structure

**Before:**
```
grafana-loki-bloom.yaml
  ├─ Secret: grafana-repo      ❌ Duplicate
  └─ Application: loki

grafana-tempo.yaml
  ├─ Secret: grafana-repo      ❌ Duplicate
  └─ Application: tempo
```

**After:**
```
repos.yaml
  ├─ Secret: grafana-repo
  ├─ Secret: prometheus-community-repo
  └─ Secret: open-telemetry-repo

grafana-loki-bloom.yaml
  └─ Application: loki          ✅ Clean

grafana-tempo.yaml
  └─ Application: tempo         ✅ Clean
```
