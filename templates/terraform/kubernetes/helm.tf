# @section services.eks.karpenterEnabled begin | displayName=Enable Karpenter | default=true
locals {
  ## Karpenter release compatible with each EKS version (Karpenter compatibility matrix)
  karpenter_versions = {
    "1.34" = "1.15.0"
    "1.35" = "1.15.0"
    "1.36" = "1.15.0"
  }

  karpenter_version = local.karpenter_versions[data.terraform_remote_state.aws.outputs.eks_kubernetes_version]
}

resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = local.karpenter_version
  wait       = false

  skip_crds  = true
  depends_on = [helm_release.karpenter_crd]

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    dnsPolicy: Default
    settings:
      clusterName: ${data.terraform_remote_state.aws.outputs.eks_cluster_name}
      clusterEndpoint: ${data.terraform_remote_state.aws.outputs.eks_cluster_endpoint}
      interruptionQueue: ${data.terraform_remote_state.aws.outputs.karpenter_interruption_queue_name}
    webhook:
      enabled: false
    EOT
  ]

  max_history = 10 # Keeps the last 10 release versions
}

resource "helm_release" "karpenter_crd" {
  namespace  = "kube-system"
  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = local.karpenter_version

  timeout     = 600 # CRD cleanup can be slow during destroy
  max_history = 10
}
# @section services.eks.karpenterEnabled end
