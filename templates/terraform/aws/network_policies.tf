# @section services.eks.networkPolicyEnabled begin
## Renders the baseline NetworkPolicies into argocd/support-resources/, where the
## support-resources ArgoCD Application picks them up. Rendered from Terraform
## rather than shipped as static YAML because admitting the EKS control plane
## needs the intra subnet CIDRs, which are only known here.
##
## kube-system is deliberately left out. It carries coredns, kube-proxy, aws-node
## and the CSI drivers, and a default-deny there takes the cluster down rather
## than hardening it.
resource "local_file" "network_policies" {
  content = templatefile(
    "${path.module}/../../argocd/support-resources/network-policies.yaml.tftpl",
    {
      ## Falls back to the private subnets when this VPC has no intra subnets,
      ## because the EKS module then places the control plane there too. An empty
      ## list would render a policy that locks the admission webhooks out.
      control_plane_cidrs = length(module.vpc.intra_subnets_cidr_blocks) > 0 ? module.vpc.intra_subnets_cidr_blocks : module.vpc.private_subnets_cidr_blocks
      load_balancer_cidrs = module.vpc.public_subnets_cidr_blocks
    }
  )
  filename = trimsuffix("${path.module}/../../argocd/support-resources/network-policies.yaml.tftpl", ".tftpl")
}
# @section services.eks.networkPolicyEnabled end
