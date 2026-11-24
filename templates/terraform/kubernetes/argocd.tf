resource "helm_release" "argocd" {
  namespace        = "argocd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.1.4"
  create_namespace = true
  timeout          = 900

  # The ingress block is only emitted when the customer gave a domain. Publishing
  # argocd.openprime.io into a customer account meant the ALB controller looked for
  # an ACM certificate for a domain they do not own, found none, and never created
  # the load balancer - so the ArgoCD UI had no address at all (OP-244).
  set = concat([
    {
      name  = "configs.params.server\\.insecure"
      value = true
    },
    ], var.ingress_domain == "" ? [] : [
    {
      name  = "global.domain"
      value = "argocd.${var.ingress_domain}"
    },
    {
      # Deliberately left ON. Disabling it was the right call on this branch, where
      # global.domain is still hardcoded to argocd.openprime.io and the ALB controller
      # therefore hunts for an ACM cert the customer does not own. OP-244 fixed that
      # cause on main instead - the whole block is now emitted only when the customer
      # supplied a domain - so on merge a `false` here silently reinstates the exact
      # outcome OP-244 shipped to remove: a customer gives a domain and still gets no
      # ArgoCD ingress. git merges the line without a conflict; only the meaning moved.
      name  = "server.ingress.enabled"
      value = true
    },
    {
      name  = "server.ingress.controller"
      value = "aws"
    },
    {
      name  = "server.ingress.ingressClassName"
      value = "alb"
    },
    {
      # ArgoCD is an admin plane with cluster-wide write access. It defaults to an
      # internal ALB; reaching it means VPN, bastion or a deliberate override.
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
      value = "internal"
    },
    {
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
      value = "ip"
    },
    {
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/backend-protocol"
      value = "HTTP"
    },
    {
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/listen-ports"
      value = "[{\"HTTPS\":443}]"
    },
    {
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/ssl-redirect"
      value = "443"
    },
    {
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/group\\.name"
      value = "essential"
    },
    {
      name  = "server.ingress.aws.serviceType"
      value = "ClusterIP"
    },
    {
      name  = "server.ingress.aws.backendProtocolVersion"
      value = "GRPC"
    },
    {
      name  = "configs.cm.url"
      value = "https://argocd.${var.ingress_domain}"
    },
    ], [
    # ACM Certificate
    # {
    #   name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    #   value = module.wildcard_cert.acm_certificate_arn
    # },
  ])
  values = concat(var.argocd_ha_enabled ? [local.argocd_ha_values] : [], local.argocd_sso_enabled ? [local.argocd_sso_values] : [])
}


locals {
  ## Every Helm repository argocd/applications.yaml installs from, plus the generated
  ## repository itself (values files and support resources). Keep in sync with
  ## applications.yaml: a chart from any other source is refused by the project.
  argocd_platform_repos = [
    var.git_repo_url,
    "https://aws.github.io/eks-charts",
    "https://charts.jetstack.io",
    "https://kubernetes-sigs.github.io/external-dns/",
    "https://kubernetes.github.io/ingress-nginx",
    "https://prometheus-community.github.io/helm-charts",
    "https://grafana.github.io/helm-charts",
  ]

  argocd_platform_namespaces = ["argocd", "kube-system", "cert-manager", "external-dns", "ingress-nginx", "monitoring"]

  ## Cluster-scoped kinds the generated charts and support resources create.
  argocd_platform_cluster_resources = [
    { group = "", kind = "Namespace" },
    { group = "apiextensions.k8s.io", kind = "CustomResourceDefinition" },
    { group = "rbac.authorization.k8s.io", kind = "ClusterRole" },
    { group = "rbac.authorization.k8s.io", kind = "ClusterRoleBinding" },
    { group = "admissionregistration.k8s.io", kind = "MutatingWebhookConfiguration" },
    { group = "admissionregistration.k8s.io", kind = "ValidatingWebhookConfiguration" },
    { group = "networking.k8s.io", kind = "IngressClass" },
    { group = "elbv2.k8s.aws", kind = "IngressClassParams" },
    { group = "scheduling.k8s.io", kind = "PriorityClass" },
    { group = "karpenter.sh", kind = "NodePool" },
    { group = "karpenter.k8s.aws", kind = "EC2NodeClass" },
  ]

  argocd_ha_values = yamlencode({
    "redis-ha"     = { enabled = true }
    controller     = { replicas = 1 }
    server         = { replicas = 2 }
    repoServer     = { replicas = 2 }
    applicationSet = { replicas = 2 }
  })

  ## SSO needs the public URL (configs.cm.url), which exists only with a domain.
  argocd_sso_enabled = var.argocd_oidc_issuer != "" && var.ingress_domain != ""

  ## The local admin is switched off only when someone else can administer Argo CD.
  argocd_local_admin_disabled = local.argocd_sso_enabled && length(var.argocd_admin_groups) > 0

  argocd_sso_values = yamlencode({
    configs = {
      cm = {
        "oidc.config" = yamlencode({
          name                     = "SSO"
          issuer                   = var.argocd_oidc_issuer
          clientID                 = var.argocd_oidc_client_id
          enablePKCEAuthentication = true
          requestedScopes          = ["openid", "profile", "email", "groups"]
        })
        "admin.enabled" = local.argocd_local_admin_disabled ? "false" : "true"
      }
      rbac = {
        "policy.default" = ""
        "policy.csv"     = join("\n", [for group in var.argocd_admin_groups : "g, ${group}, role:admin"])
        scopes           = "[groups]"
      }
    }
  })
}

## The built-in project allows every repository, destination and cluster-scoped
## resource, so anyone who can write to the repository is effectively cluster-admin.
## Created after the Applications have moved to their own projects, so an existing environment is not denied mid-apply.
resource "kubectl_manifest" "argocd_project_default" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "default"
      namespace = "argocd"
    }
    spec = {
      sourceRepos                = []
      sourceNamespaces           = []
      destinations               = []
      namespaceResourceBlacklist = [{ group = "*", kind = "*" }]
    }
  })

  depends_on = [
    kubectl_manifest.app_of_apps,
    kubectl_manifest.support_resources,
  ]
}

resource "kubectl_manifest" "argocd_project_platform" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "platform"
      namespace = "argocd"
    }
    spec = {
      description              = "Cluster add-ons generated by OpenPrime"
      sourceRepos              = local.argocd_platform_repos
      destinations             = [for namespace in local.argocd_platform_namespaces : { server = "https://kubernetes.default.svc", namespace = namespace }]
      clusterResourceWhitelist = local.argocd_platform_cluster_resources
    }
  })

  wait = true

  depends_on = [helm_release.argocd]
}

## For the customer's own workloads: only the generated repository, namespaced
## resources only, and none of the platform namespaces.
resource "kubectl_manifest" "argocd_project_applications" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "applications"
      namespace = "argocd"
    }
    spec = {
      description              = "Customer workloads"
      sourceRepos              = [var.git_repo_url]
      destinations             = concat([{ server = "https://kubernetes.default.svc", namespace = "*" }], [for namespace in local.argocd_platform_namespaces : { server = "https://kubernetes.default.svc", namespace = "!${namespace}" }])
      clusterResourceWhitelist = []
    }
  })

  depends_on = [helm_release.argocd]
}

# Git repository credentials — Applications depend on this so that
# during `terraform destroy` the secret is removed AFTER ArgoCD has
# finished finalizing (cleaning up child resources via the repo).
resource "kubectl_manifest" "repo_secret" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "argocd-repo"
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    stringData = {
      type          = "git"
      name          = "github"
      url           = var.git_repo_url
      sshPrivateKey = var.git_repo_ssh_key
    }
  })

  wait = true

  depends_on = [helm_release.argocd]
}

# ArgoCD Applications — all depend on repo_secret so that during
# destroy, Terraform deletes Applications first (triggering ArgoCD
# finalizer cleanup with SSH key still available), then removes
# the repo secret, then the ArgoCD helm release.

# Using 'gavinbunney/kubectl' instead of official Kubernetes provider
# to allow applying manifest without checking for CRDs during plan.
# @section services.eks.exampleAppsEnabled begin | displayName=Deploy example applications | default=false
resource "kubectl_manifest" "example_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "example-apps"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
      annotations = {
        "argocd.argoproj.io/sync-wave" = "3"
      }
    }
    spec = {
      project = "platform"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_target_revision
        path           = "argocd/example-apps"
        directory = {
          recurse = true
        }
      }
      destination = {
        name      = "in-cluster"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })

  wait = true

  depends_on = [kubectl_manifest.app_of_apps]
}
# @section services.eks.exampleAppsEnabled end

resource "kubectl_manifest" "support_resources" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "support-resources"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
      annotations = {
        "argocd.argoproj.io/sync-wave" = "3"
      }
    }
    spec = {
      project = "platform"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_target_revision
        path           = "argocd/support-resources"
        directory = {
          recurse = true
        }
      }
      destination = {
        name      = "in-cluster"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  })

  wait = true

  depends_on = [
    kubectl_manifest.repo_secret,
    kubectl_manifest.argocd_project_platform,
    # @section services.eks.karpenterEnabled begin
    helm_release.karpenter,
    # @section services.eks.karpenterEnabled end
  ]
}

resource "kubectl_manifest" "app_of_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "platform"
      source = {
        repoURL        = var.git_repo_url
        path           = "argocd/charts/internal/app-of-apps"
        targetRevision = var.git_target_revision
        helm = {
          valueFiles = [
            "$values/argocd/applications.yaml"
          ]
        }
      }
      destination = {
        name      = "in-cluster"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PruneLast=true",
          "PrunePropagationPolicy=foreground",
        ]
      }
    }
  })

  wait = true

  depends_on = [
    kubectl_manifest.repo_secret,
    kubectl_manifest.support_resources,
    kubectl_manifest.argocd_project_platform,
  ]
}
