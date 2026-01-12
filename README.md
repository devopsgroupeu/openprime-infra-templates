# OpenPrime Infrastructure Templates

Infrastructure-as-Code templates for deploying AWS-based Kubernetes environments using Terraform and ArgoCD.

## Overview

This repository contains production-ready templates for:
- **Terraform** - AWS infrastructure (VPC, EKS, RDS, etc.)
- **ArgoCD** - GitOps application manifests
- **Helm** - Kubernetes application values

## Directory Structure

```
templates/
├── terraform/
│   ├── aws/           # AWS infrastructure modules
│   └── kubernetes/    # Kubernetes Terraform (ArgoCD bootstrap)
├── argocd/
│   ├── applications.yaml    # App-of-apps manifest
│   ├── infra-apps/          # Infrastructure ArgoCD apps
│   └── charts/external/     # Vendored Helm charts
└── helm/                    # Helm values templates

local/
├── data/              # YAML configuration layers
└── terraforge.sh      # Template processor script
```

## Template System

Templates use comment-based decorators for conditional inclusion and parameterization:

```terraform
# @section services.eks.enabled begin
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  # @param eks.kubernetes_version
  kubernetes_version = "1.33"
}
# @section services.eks.enabled end
```

### Decorators

- `# @section <condition> begin/end` - Conditional section boundaries
- `# @param <variable>` - Configurable parameter marker

## AWS Infrastructure

### Terraform Modules

| Module | Purpose |
|--------|---------|
| `vpc.tf` | VPC with multi-AZ subnets |
| `eks.tf` | EKS cluster + managed node groups |
| `karpenter.tf` | Karpenter autoscaler |
| `database.tf` | RDS/Aurora PostgreSQL |
| `ecr.tf` | Container registries |

### Requirements

- Terraform ~> 1.11
- AWS Provider >= 6.0
- Kubernetes 1.33 (default)

## ArgoCD App-of-Apps

Bundled Helm charts in `templates/argocd/charts/external/`:
- ArgoCD 8.2.5, Argo Workflows 0.45.19
- kube-prometheus-stack 75.9.0, Loki 6.30.1
- ingress-nginx 4.13.0, cert-manager 1.18.2
- And more...

## Usage

### Direct Usage

Templates contain sensible defaults in `terraform.auto.tfvars`:

```bash
cd templates/terraform/aws
terraform init
terraform plan
terraform apply
```

### With Injecto Processing

Use [Injecto](https://github.com/devopsgroupeu/Injecto) to process templates with custom YAML configuration:

```bash
python3 injecto/src/main.py \
  --input-dir templates/ \
  --output-dir output/ \
  --data-files config.yaml
```

## Configuration Layers

The hierarchical YAML system merges configs from multiple files:

```
local/data/
├── 00_base.yaml       # Foundation (backend, global prefix)
├── 01_startup.yaml    # Basic stack (VPC, EKS, RDS)
├── 02_standard.yaml   # Extended services
├── 03_premium.yaml    # Enterprise features
├── 04_addons.yaml     # Optional add-ons
└── 10_override.yaml   # Environment overrides
```

## Related Repositories

- [Injecto](https://github.com/devopsgroupeu/Injecto) - Template processor
- [StateCraft](https://github.com/devopsgroupeu/StateCraft) - Terraform backend manager
- [openprime-app](https://github.com/devopsgroupeu/openprime-app) - Frontend generating these configs

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
