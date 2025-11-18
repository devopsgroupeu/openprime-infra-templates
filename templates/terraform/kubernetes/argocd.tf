resource "helm_release" "argocd" {
  namespace  = "argocd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.0.7"

  create_namespace = true

  values = [
    <<-EOT
    server:
      ingress:
        enabled: false
        controller: aws
        ingressClassName: alb
        annotations:
          alb.ingress.kubernetes.io/scheme: internal
          alb.ingress.kubernetes.io/target-type: ip
          alb.ingress.kubernetes.io/backend-protocol: HTTP
          alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
          alb.ingress.kubernetes.io/ssl-redirect: '443'
        aws:
          serviceType: ClusterIP # <- Used with target-type: ip
          backendProtocolVersion: GRPC

    configs:
      params:
        server.insecure: true
      repositories:
        dog-gitlab-repo:
          url: ${var.git_repo_url}
          type: git
          name: GitLab
      ssh:
        extraHosts: |
          ${var.selfhosted_git_server_fingerprint}
    EOT
  ]

  set_sensitive {
    name  = "configs.repositories.dog-gitlab-repo.sshPrivateKey"
    value = var.git_repo_private_key
  }
}

# Using 'gavinbunney/kubectl' instead of official Kubernetes provider to allow applying manifest without checking for CRDs during plan
resource "kubectl_manifest" "infra_apps" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: infra-apps
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
      annotations:
        argocd.argoproj.io/sync-wave: "2" # Default wave is 0 (0 is the earliest)
    spec:
      project: default
      source:
        repoURL: ${var.git_repo_url}
        targetRevision: ${var.git_target_revision}
        path: argocd/infra-apps
        directory:
          recurse: true
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
  YAML

  wait = true

  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "support_resources" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: support-resources
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
      annotations:
        argocd.argoproj.io/sync-wave: "3" # Default wave is 0 (0 means early)
    spec:
      project: default
      source:
        repoURL: ${var.git_repo_url}
        targetRevision: ${var.git_target_revision}
        path: argocd/support-resources
        directory:
          recurse: true
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
  YAML

  wait = true

  depends_on = [helm_release.argocd, kubectl_manifest.infra_apps]
}
