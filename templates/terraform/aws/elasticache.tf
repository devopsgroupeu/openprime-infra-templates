# @section services.elasticache.enabled begin
module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.10"

  replication_group_id = "${var.global_prefix}-elasticache"

  engine                     = var.elasticache_engine
  engine_version             = var.elasticache_engine_version
  node_type                  = var.elasticache_node_type
  transit_encryption_enabled = var.elasticache_transit_encryption_enabled
  at_rest_encryption_enabled = var.elasticache_at_rest_encryption_enabled
  auth_token                 = var.elasticache_auth_token_enabled ? random_password.elasticache_auth_token[0].result : null
  maintenance_window         = var.elasticache_maintenance_window
  apply_immediately          = true
  snapshot_retention_limit   = var.elasticache_snapshot_retention_limit
  snapshot_window            = var.elasticache_snapshot_window
  automatic_failover_enabled = var.elasticache_automatic_failover_enabled
  multi_az_enabled           = var.elasticache_multi_az_enabled

  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  subnet_group_name        = "${var.global_prefix}-elasticache"
  subnet_group_description = "ElastiCache subnet group"
  subnet_ids               = module.vpc.private_subnets

  create_parameter_group      = true
  parameter_group_name        = "${var.global_prefix}-elasticache"
  parameter_group_family      = var.elasticache_parameter_group_family
  parameter_group_description = "ElastiCache parameter group"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = var.global_tags
}

resource "random_password" "elasticache_auth_token" {
  count = var.elasticache_auth_token_enabled ? 1 : 0

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}|:;<>,.?"
}
# @section services.elasticache.enabled end
