# @section vpc begin
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  nat_gateway = {
    enable_nat_gateway     = coalesce(var.nat_gateway_strategy == "NO_NAT" ? false : true)
    single_nat_gateway     = coalesce(var.nat_gateway_strategy == "SINGLE" ? true : false)
    one_nat_gateway_per_az = coalesce(var.nat_gateway_strategy == "ONE_PER_AZ" ? true : false)
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.global_prefix}vpc-${var.environment_short}"
  cidr = var.vpc_cidr

  azs              = local.azs
  private_subnets  = var.create_private_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)] : []
  public_subnets   = var.create_public_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)] : []
  intra_subnets    = var.create_intra_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)] : []
  database_subnets = var.create_database_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 56)] : []

  # @param vpc.enable_dns_hostnames
  enable_dns_hostnames = true
  # @param vpc.enable_dns_support
  enable_dns_support     = true
  enable_nat_gateway     = local.nat_gateway.enable_nat_gateway
  single_nat_gateway     = local.nat_gateway.single_nat_gateway
  one_nat_gateway_per_az = local.nat_gateway.one_nat_gateway_per_az

  # @param vpc.create_database_subnet_group
  create_database_subnet_group = true

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }, var.public_subnet_tags)

  private_subnet_tags = merge({
    "karpenter.sh/discovery"                      = local.cluster_name
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }, var.private_subnet_tags)

  database_subnet_tags = var.database_subnet_tags
}
# @section vpc end
