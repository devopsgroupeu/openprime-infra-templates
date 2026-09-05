# OpenPrime Infrastructure Templates

Infrastructure-as-Code templates for deploying AWS-based Kubernetes environments using Terraform and ArgoCD.

## Overview

This repository contains production-ready templates for:
- **Terraform** - AWS infrastructure (VPC, EKS, RDS, etc.)
- **ArgoCD** - GitOps application manifests
- **Helm** - Kubernetes application values

## Directory Structure

Everything below is tracked in git; a fresh clone contains exactly this.

```
templates/                       # the tree Injecto processes (input_dir)
├── .github/workflows/           # terraform-deploy.yml, shipped to the customer's repo
├── .gitlab-ci.yml               # GitLab equivalent, also shipped
├── terraform/
│   ├── aws/                     # VPC, EKS, RDS, ECR, Karpenter, helm_values
│   └── kubernetes/              # ArgoCD bootstrap
└── argocd/
    ├── applications.yaml        # app-of-apps manifest (@section-gated)
    ├── charts/internal/         # app-of-apps Helm chart
    ├── example-apps/            # sample workloads
    ├── support-resources/       # Karpenter + NetworkPolicy configs
    └── values/                  # Helm values (.yaml and .yaml.tftpl)

tests/                           # generation gate (see tests/README.md)
```

> [!note]
> `local/` is **gitignored** and is not part of a clone. Older revisions of this file documented `local/data/*.yaml` tiers and a `terraforge.sh` processor as if they shipped; they do not. The tiers also use a retired namespace (`vpc:` / `eks:` / `backend:`) that the templates no longer read, so they cannot be used to drive generation. The canonical data shape is the one the backend sends — see `tests/fixtures/standard.json`.

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

Injecto recognises exactly three. The grammar is defined once, in Injecto's
`injecto/decorators.py`, and imported by both the substituter and the catalog
extractor so the two cannot disagree.

- `# @param <dot.path>` - replaces the value on the **following value line**
- `# @module <dot.path>` - declares a service to the wizard catalog; no effect on substitution
- `# @section <dot.path> begin/end` - comments the block out when the path is falsy

`@param` and `@module` may carry an attribute tail, which the substituter ignores
and the catalog extractor reads:

```
# @param services.ecr.repositoryNames | type=list
# @param services.sns.kmsKeyId | type=string | default=
# @module services.eks | displayName=Elastic Kubernetes Service (EKS) | category=Compute
```

`@module` is what puts a service on the wizard's grid and gives it its label.
`available=false` keeps a service out of the wizard while leaving its Terraform in
place — `lambda` uses this, because it generates fine but expects deployment
packages the wizard cannot supply.

> A `|` inside an attribute value splits the decorator, so regex alternation in
> `pattern` is not supported. The gate fails rather than shipping a mangled value.

`type` is required only where the literal is ambiguous — `null`, `[]`, or a
quoted boolean reveal no usable type and are rejected rather than guessed.

The extractor also checks that each path maps to its Terraform variable under
one of two conventions:

| Convention | Example |
|------------|---------|
| leaf | `services.vpc.azCount` -> `az_count` |
| service-prefixed | `services.rds.engineVersion` -> `rds_engine_version` |

Nine existing paths predate both and are listed in `catalog/legacy-paths.txt`.
They are pinned by saved environments and by the frontend wire contract, so
renaming them is a breaking change. New paths must follow a convention instead
of being added to that file.

Both rules are enforced on every pull request by the `catalog-gate` job.

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

`templates/argocd/applications.yaml` declares the app-of-apps, with each entry gated by a `@section helmCharts.<name>.enabled` decorator. The chart itself lives in `templates/argocd/charts/internal/app-of-apps/`, and per-chart values in `templates/argocd/values/` (plain `.yaml`, or `.yaml.tftpl` when a value has to be rendered from a Terraform output).

Charts are pulled from their upstream repositories at sync time — **nothing is vendored in this repo**. Earlier revisions listed pinned chart versions under `templates/argocd/charts/external/`; that directory has no tracked files and the list matched nothing.

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

## Configuration Data

Injecto resolves every `@param` path against one merged data document. In production that document is built by the backend (`prepareInjectoData`, `openprime-app-backend/src/services/environmentService.js`) and posted to Injecto's `/process-git-download`.

The top-level keys the templates actually read:

| Key | Used for |
|-----|----------|
| `services.*` | per-service enablement and settings (`vpc`, `eks`, `rds`, `ecr`, …) |
| `terraformBackend.*` | state bucket, per-environment state keys, encryption, locking |
| `global.*` | resource naming prefix |
| `argocd.*` | git repo URL and target revision for the app-of-apps |
| `helmCharts.*` | which charts the app-of-apps includes |

`tests/fixtures/standard.json` is a worked example in exactly this shape and is what the CI gate generates from.

## Testing

`tests/gate.py` runs Injecto over the tracked templates with a fixture and fails on the things Injecto only warns about: dropped files, an `@param` that did not resolve under an enabled service, a resolved param whose output still holds the template default, and newly inert decorators. See `tests/README.md`.

## Related Repositories

- [Injecto](https://github.com/devopsgroupeu/Injecto) - Template processor
- [StateCraft](https://github.com/devopsgroupeu/StateCraft) - Terraform backend manager
- [openprime-app](https://github.com/devopsgroupeu/openprime-app) - Frontend generating these configs

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.