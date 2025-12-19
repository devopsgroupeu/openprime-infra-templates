# Retrieve SSH private key from AWS Secrets Manager
# YOU NEED TO CREATE THE SECRET BEFOREHAND: `aws secretsmanager create-secret --name argocd/git-ssh-private-key --secret-string "$(cat ~/.ssh/id_ed25519)"`
data "aws_secretsmanager_secret_version" "argocd_ssh_key" {
  secret_id = "argocd/git-ssh-private-key"
}

resource "helm_release" "argocd" {
  namespace        = "argocd"
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.1.4"
  create_namespace = true

  set = [
    {
      name  = "global.domain"
      value = "argocd.openprime.io"
    },
    {
      name  = "configs.params.server\\.insecure"
      value = true
    },
    {
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
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
      value = "internet-facing"
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
    # ACM Certificate
    # {
    #   name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    #   value = module.wildcard_cert.acm_certificate_arn
    # },
    # HA setup
    # {
    #   name  = "redis-ha.enabled"
    #   value = true
    # },
    # {
    #   name  = "controller.replicas"
    #   value = 1
    # },
    # {
    #   name  = "server.replicas"
    #   value = 2
    # },
    # {
    #   name  = "repoServer.replicas"
    #   value = 2
    # },
    # {
    #   name  = "applicationSet.replicas"
    #   value = 2
    # },
  ]
}


# Using 'gavinbunney/kubectl' instead of official Kubernetes provider to allow applying manifest without checking for CRDs during plan
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
      project = "default"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_target_revision
        path           = "templates/argocd/example-apps"
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

  depends_on = [helm_release.argocd]
}

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
      project = "default"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_target_revision
        path           = "templates/argocd/support-resources"
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

  depends_on = [helm_release.argocd]
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
      project = "default"
      source = {
        repoURL        = var.git_repo_url
        path           = "templates/argocd/charts/internal/app-of-apps"
        targetRevision = var.git_target_revision
        helm = {
          valueFiles = [
            "$values/templates/argocd/applications.yaml"
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
          "CreateNamespace=true"
        ]
      }
    }
  })

  wait = true

  depends_on = [helm_release.argocd]
}

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
      project       = "default"
      url           = var.git_repo_url
      sshPrivateKey = data.aws_secretsmanager_secret_version.argocd_ssh_key.secret_string
    }
  })

  wait = true

  depends_on = [helm_release.argocd]
}
