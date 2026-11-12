# @section services.eks.enabled begin
locals {
  cluster_name                 = "${var.global_prefix}eks-${var.environment}"
  service_account_namespace    = "kube-system"
  ebs_csi_service_account_name = "ebs-csi-controller-sa"
  efs_csi_service_account_name = "efs-csi-controller-sa"
  vpc_cni_service_account_name = "aws-node"
  aws_lb_service_account_name  = "aws-lb-controller-sa"
}

locals {
  ## EKS add-on versions are pinned per Kubernetes minor version so an apply never
  ## changes them on its own. Bump deliberately, in dev first. List candidates with:
  ## aws eks describe-addon-versions --addon-name <addon> --kubernetes-version <version>
  eks_addon_versions = {
    "1.36" = {
      coredns      = "v1.14.7-eksbuild.35"
      pod_identity = "v1.4.1-eksbuild.3"
      kube_proxy   = "v1.36.0-eksbuild.65"
      vpc_cni      = "v1.23.3-eksbuild.1"
      ebs_csi      = "v1.68.0-eksbuild.1"
      efs_csi      = "v3.5.4-eksbuild.1"
    }
    "1.35" = {
      coredns      = "v1.14.7-eksbuild.35"
      pod_identity = "v1.4.1-eksbuild.3"
      kube_proxy   = "v1.35.3-eksbuild.69"
      vpc_cni      = "v1.23.3-eksbuild.1"
      ebs_csi      = "v1.68.0-eksbuild.1"
      efs_csi      = "v3.5.4-eksbuild.1"
    }
    "1.34" = {
      coredns      = "v1.13.2-eksbuild.75"
      pod_identity = "v1.4.1-eksbuild.3"
      kube_proxy   = "v1.34.6-eksbuild.69"
      vpc_cni      = "v1.23.3-eksbuild.1"
      ebs_csi      = "v1.68.0-eksbuild.1"
      efs_csi      = "v3.5.4-eksbuild.1"
    }
  }

  eks_addon_version = local.eks_addon_versions[var.kubernetes_version]
}

## use_name_prefix governs the policy name as well as the role name. Left at false
## with no policy_name the module falls back to a constant ("EBS_CSI", "VPC_CNI_IPv4",
## ...), which is account-global: a second environment in the same AWS account then
## fails with EntityAlreadyExists and its nodes never join the cluster.
module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                  = "${local.cluster_name}-ebs-csi"
  use_name_prefix       = false
  policy_name           = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.ebs_csi_service_account_name}"]
    }
  }
}

module "efs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                  = "${local.cluster_name}-efs-csi"
  use_name_prefix       = false
  policy_name           = "${local.cluster_name}-efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.efs_csi_service_account_name}"]
    }
  }
}

module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                  = "${local.cluster_name}-vpc-cni"
  use_name_prefix       = false
  policy_name           = "${local.cluster_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.vpc_cni_service_account_name}"]
    }
  }
}

module "alb_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                                   = "${local.cluster_name}-aws-lb-controller"
  use_name_prefix                        = false
  policy_name                            = "${local.cluster_name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.aws_lb_service_account_name}"]
    }
  }
}

module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                       = "${local.cluster_name}-external-dns"
  use_name_prefix            = false
  policy_name                = "${local.cluster_name}-external-dns"
  attach_external_dns_policy = true

  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns-sa"]
    }
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.25"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  endpoint_public_access                   = var.endpoint_public_access
  authentication_mode                      = var.authentication_mode
  enable_irsa                              = var.enable_irsa

  addons = {
    coredns = {
      addon_version = local.eks_addon_version.coredns
    }
    eks-pod-identity-agent = {
      addon_version  = local.eks_addon_version.pod_identity
      before_compute = var.eks_addon_pod_identity_before_compute
    }
    kube-proxy = {
      addon_version = local.eks_addon_version.kube_proxy
    }
    vpc-cni = {
      service_account_role_arn = module.vpc_cni_irsa_role.arn
      addon_version            = local.eks_addon_version.vpc_cni
      before_compute           = var.eks_addon_vpc_cni_before_compute

      ## Without this the API server accepts NetworkPolicy objects and the CNI
      ## enforces none of them - a security control that looks present and is not.
      ## Enforcement on its own changes no traffic: a pod is restricted only once
      ## some policy selects it, so this is inert until policies are generated.
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.arn
      addon_version            = local.eks_addon_version.ebs_csi
      configuration_values = jsonencode({
        controller = {
          extraVolumeTags = local.apn_tags
        }
      })
    }
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_irsa_role.arn
      addon_version            = local.eks_addon_version.efs_csi
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets



  eks_managed_node_groups = {
    default = {
      ami_type                       = var.default_node_group_ami_type
      instance_types                 = var.default_node_group_instance_types
      capacity_type                  = var.default_node_group_capacity_type
      use_latest_ami_release_version = var.default_node_group_use_latest_ami

      iam_role_additional_policies = var.default_node_group_iam_additional_policies

      min_size     = var.default_node_group_min_size
      max_size     = var.default_node_group_max_size
      desired_size = var.default_node_group_desired_size

      labels = {
        Name = "default"
        ## Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }

      update_config = {
        "max_unavailable" = var.default_node_group_max_unavailable
      }
    }
  }

  node_security_group_tags = {
    ## NOTE - if creating multiple security groups with this module, only tag the
    ## security group that Karpenter should utilize with the following tag
    ## (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  }

  ## Provider default_tags do not reach node group launch template tag_specifications (instances, volumes, ENIs)
  tags = merge(var.global_tags, local.apn_tags)
}
# @section services.eks.enabled end
