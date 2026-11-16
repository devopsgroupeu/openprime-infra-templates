# @section services.vpc begin
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

module "flow_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.15"

  count = var.enable_flow_logs && var.flow_log_bucket_arn == "" ? 1 : 0

  bucket        = "${var.global_prefix}vpc-flow-logs-${var.environment}"
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  tags = var.global_tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7"

  name = "${var.global_prefix}vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs              = local.azs
  private_subnets  = var.create_private_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)] : []
  public_subnets   = var.create_public_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)] : []
  intra_subnets    = var.create_intra_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)] : []
  database_subnets = var.create_database_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 56)] : []

  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_dns_support     = var.enable_dns_support
  enable_nat_gateway     = local.nat_gateway.enable_nat_gateway
  single_nat_gateway     = local.nat_gateway.single_nat_gateway
  one_nat_gateway_per_az = local.nat_gateway.one_nat_gateway_per_az

  enable_vpn_gateway        = var.enable_vpn_gateway
  enable_flow_log           = var.enable_flow_logs
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = var.flow_log_bucket_arn != "" ? var.flow_log_bucket_arn : one(module.flow_logs_bucket[*].s3_bucket_arn)

  create_database_subnet_group = var.create_database_subnet_group

  public_subnet_tags = merge({
    # @section services.eks.enabled begin
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
    # @section services.eks.enabled end
  }, var.public_subnet_tags)

  private_subnet_tags = merge({
    # @section services.eks.enabled begin
    "karpenter.sh/discovery"                      = local.cluster_name
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    # @section services.eks.enabled end
  }, var.private_subnet_tags)

  database_subnet_tags = var.database_subnet_tags
}
# @section services.vpc end
