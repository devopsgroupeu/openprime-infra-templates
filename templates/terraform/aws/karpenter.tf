# @section services.eks.karpenterEnabled begin
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = module.eks.cluster_name

  node_iam_role_use_name_prefix   = var.karpenter_node_iam_role_use_name_prefix
  node_iam_role_name              = "${data.aws_caller_identity.current.account_id}-${lower(local.cluster_name)}-karpenter"
  create_pod_identity_association = var.karpenter_create_pod_identity_association

  ## Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = var.karpenter_node_iam_role_additional_policies
}

## Generate Karpenter support resources (EC2NodeClass and NodePool)
resource "local_file" "karpenter_support_resources" {
  content = templatefile(
    "${path.module}/../../argocd/support-resources/karpenter.yaml.tftpl",
    {
      cluster_name       = module.eks.cluster_name
      node_iam_role_name = module.karpenter.node_iam_role_name
      arch               = var.karpenter_nodepool_arch
      capacity_type      = var.karpenter_nodepool_capacity_type
    }
  )
  filename = trimsuffix("${path.module}/../../argocd/support-resources/karpenter.yaml.tftpl", ".tftpl")
}

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
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
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
