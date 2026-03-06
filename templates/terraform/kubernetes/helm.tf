# @section services.eks.karpenterEnabled begin
resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.9.0"
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
  version    = "1.9.0"

  max_history = 10 # Keeps the last 10 release versions
}
# @section services.eks.karpenterEnabled end
