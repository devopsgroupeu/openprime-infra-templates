# @section services.eks.enabled begin
locals {
  cluster_name                 = "${var.global_prefix}eks-${var.environment_short}"
  service_account_namespace    = "kube-system"
  ebs_csi_service_account_name = "ebs-csi-controller-sa"
  efs_csi_service_account_name = "efs-csi-controller-sa"
  vpc_cni_service_account_name = "aws-node"
  aws_lb_service_account_name  = "aws-lb-controller-sa"
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.59"

  role_name             = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.ebs_csi_service_account_name}"]
    }
  }
}

module "efs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.59"

  role_name             = "${local.cluster_name}-efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.efs_csi_service_account_name}"]
    }
  }
}

module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.59"

  role_name             = "${local.cluster_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.vpc_cni_service_account_name}"]
    }
  }
}

# @section aws_load_balancer_controller.enable begin
module "alb_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.59"

  role_name                              = "${local.cluster_name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    default = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.service_account_namespace}:${local.aws_lb_service_account_name}"]
    }
  }
}
# @section aws_load_balancer_controller.enable end

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  endpoint_public_access                   = var.endpoint_public_access
  authentication_mode                      = var.authentication_mode
  enable_irsa                              = var.enable_irsa

  addons = {
    coredns = {
      most_recent = var.eks_addon_coredns_most_recent
    }
    eks-pod-identity-agent = {
      most_recent    = var.eks_addon_pod_identity_most_recent
      before_compute = var.eks_addon_pod_identity_before_compute
    }
    kube-proxy = {
      most_recent = var.eks_addon_kube_proxy_most_recent
    }
    vpc-cni = {
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
      most_recent              = var.eks_addon_vpc_cni_most_recent
      before_compute           = var.eks_addon_vpc_cni_before_compute
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      most_recent              = var.eks_addon_ebs_csi_most_recent
    }
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_irsa_role.iam_role_arn
      most_recent              = var.eks_addon_efs_csi_most_recent
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
}
# @section services.eks.enabled end
