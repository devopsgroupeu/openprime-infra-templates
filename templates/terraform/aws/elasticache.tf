# No separator dash before "elasticache" below: global_prefix already ends
# in one (see _variables.tf's validation). An explicit dash would double it
# into "prefix--elasticache", and AWS rejects two consecutive hyphens in a
# replication group id, subnet group name or parameter group name.
#
# This comment has to live outside the @section block below, not next to
# the lines it explains: Injecto's section toggling strips exactly one
# leading "#" from every line inside an enabled section to "activate" it
# (src/processing.py, Pass 1) - it can't tell a genuine comment from a
# disabled placeholder line, so a "#" comment inside the section becomes
# bare invalid text the moment the section is enabled and terraform fmt
# fails to parse it. Confirmed by actually enabling elasticache in
# tests/fixtures/standard.json and running Injecto against it.
# @section services.elasticache.enabled begin
module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.11"

  replication_group_id = "${var.global_prefix}elasticache"

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

  subnet_group_name        = "${var.global_prefix}elasticache"
  subnet_group_description = "ElastiCache subnet group"
  subnet_ids               = module.vpc.private_subnets

  create_parameter_group      = true
  parameter_group_name        = "${var.global_prefix}elasticache"
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
