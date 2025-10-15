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

  name = local.cluster_name
  # @param services.eks.kubernetesVersion
  kubernetes_version = "1.33"

  # @param services.eks.enableClusterCreatorAdminPermissions
  enable_cluster_creator_admin_permissions = true
  # @param services.eks.endpointPublicAccess
  endpoint_public_access = true
  authentication_mode    = "API"
  enable_irsa            = true

  addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
      most_recent              = true
      before_compute           = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      most_recent              = true
    }
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_irsa_role.iam_role_arn
      most_recent              = true
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
      use_latest_ami_release_version = true

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      min_size     = 1
      max_size     = var.default_node_group_nodes_count
      desired_size = var.default_node_group_nodes_count

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
