# Helm Charts Repository

This directory contains locally stored official Helm charts for the OpenPrime infrastructure, organized for AWS EKS deployment.

## Structure

```
helm-charts/
├── observability/          # Observability stack charts
│   ├── prometheus-community/
│   │   └── kube-prometheus-stack/  # Prometheus, Grafana, Alertmanager
│   ├── grafana/
│   │   ├── loki/                    # Log aggregation
│   │   ├── promtail/                # Log collector
│   │   └── tempo-distributed/       # Distributed tracing
│   └── bitnami/
│       └── thanos/                  # Long-term metrics storage
├── ingress/                # Ingress controllers
│   └── ingress-nginx/
├── cert-manager/           # Certificate management
│   └── cert-manager/
└── values/                 # Custom values overlays for AWS EKS
    ├── observability/
    │   ├── prometheus-stack-values.yaml
    │   ├── loki-values.yaml
    │   ├── promtail-values.yaml
    │   ├── additional-prometheus-rules.yaml
    │   └── enable-loki.yaml
    ├── ingress/
    │   └── ingress-nginx-values.yaml
    └── cert-manager/
        └── cluster-issuer.yaml
```

## Chart Versions

| Chart | Version | Repository |
|-------|---------|------------|
| kube-prometheus-stack | 75.9.0 | prometheus-community |
| loki | 6.30.1 | grafana |
| promtail | 6.17.0 | grafana |
| tempo-distributed | 1.45.0 | grafana |
| thanos | 17.2.1 | bitnami |
| ingress-nginx | 4.13.0 | ingress-nginx |
| cert-manager | 1.18.2 | jetstack |

## Usage

### Deploying with Helm

```bash
# Example: Deploy Prometheus Stack
helm upgrade --install kube-prometheus-stack \\
  ./observability/prometheus-community/kube-prometheus-stack \\
  -f ./values/observability/prometheus-stack-values.yaml \\
  --namespace monitoring --create-namespace

# Example: Deploy Loki with AWS S3
helm upgrade --install loki \\
  ./observability/grafana/loki \\
  -f ./values/observability/loki-values.yaml \\
  --namespace monitoring
```

### Deploying with ArgoCD

Charts are referenced in `../templates/argocd/applications.yaml` and deployed via ArgoCD.

## AWS EKS Configuration

### Prerequisites

1. **IAM Roles for Service Accounts (IRSA)** configured for:
   - Loki (S3 access)
   - Thanos (S3 access)
   - cert-manager (Route53 for DNS01 challenges)
   - ingress-nginx (ALB/NLB management)

2. **S3 Buckets** for:
   - Loki chunks and ruler
   - Thanos long-term storage

3. **StorageClass** `gp2` or `gp3` for EBS volumes

### Customization

Edit values files in `values/` directory:
- Replace `<REGION>`, `<S3_BUCKET_*>`, `<*_ROLE_ARN>` placeholders with actual values
- Configure retention policies
- Adjust resource requests/limits for your cluster size

## Updating Charts

To update to newer chart versions:

```bash
# Add/update repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Pull new version
helm pull grafana/loki --version <NEW_VERSION> --untar --untardir ./observability/grafana/

# Update applications.yaml with new path/version
```

## Gateway API (Future)

Gateway API charts will be added to support parallel deployment with Ingress-nginx for gradual migration.
