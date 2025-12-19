locals {
  # Sanitized prefix for resources that don't allow dashes (RDS db names, usernames)
  global_prefix_sanitized = replace(var.global_prefix, "-", "")

  # @section services.rds.enabled begin
  rds_identifier          = "${var.global_prefix}rds-${var.environment_short}"
  rds_db_name             = "${local.global_prefix_sanitized}db${var.environment_short}"
  rds_username            = "${local.global_prefix_sanitized}rdsuser${var.environment_short}"
  rds_sg_vpc_rule_name    = var.rds_engine == "postgres" ? "postgresql-tcp" : "mysql-tcp"
  rds_port                = var.rds_engine == "postgres" ? 5432 : 3306
  cloudwatch_logs_exports = var.rds_engine == "postgres" ? ["postgresql"] : ["error", "general", "slowquery"]
  # @section services.rds.enabled end

  # @section services.aurora.enabled begin
  aurora_name             = "${var.global_prefix}aurora-${var.environment_short}"
  aurora_database_name    = "${local.global_prefix_sanitized}auroradb${var.environment_short}"
  aurora_username         = "${local.global_prefix_sanitized}aurorauser${var.environment_short}"
  aurora_sg_vpc_rule_name = var.aurora_engine == "aurora-postgresql" ? "postgresql-tcp" : "mysql-tcp"
  aurora_port             = var.aurora_engine == "aurora-postgresql" ? 5432 : 3306
  # @section services.aurora.enabled end
}

# @section services.rds.enabled begin
resource "random_password" "rds_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
# @section services.rds.enabled end

# @section services.aurora.enabled begin
resource "random_password" "aurora_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
# @section services.aurora.enabled end

# @section services.rds.enabled begin
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12"

  identifier = local.rds_identifier

  subnet_ids             = module.vpc.database_subnets
  create_db_subnet_group = true
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  apply_immediately         = var.rds_apply_immediately
  deletion_protection       = var.rds_deletion_protection
  skip_final_snapshot       = var.rds_skip_final_snapshot
  create_db_option_group    = true
  create_db_parameter_group = true
  delete_automated_backups  = var.rds_delete_automated_backups
  backup_retention_period   = var.rds_backup_retention_period

  engine                     = var.rds_engine
  engine_version             = var.rds_engine_version
  major_engine_version       = var.rds_major_engine_version
  family                     = var.rds_family
  instance_class             = var.rds_instance_class
  multi_az                   = var.rds_multi_az
  auto_minor_version_upgrade = var.rds_auto_minor_version_upgrade

  db_name                     = local.rds_db_name
  manage_master_user_password = var.rds_manage_master_user_password
  username                    = local.rds_username
  password                    = random_password.rds_password.result
  port                        = local.rds_port

  storage_encrypted     = true
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  publicly_accessible                 = var.rds_publicly_accessible

  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  create_monitoring_role                = true
  monitoring_role_name                  = "${var.global_prefix}rds-monitoring-role"
  monitoring_interval                   = var.rds_monitoring_interval
  enabled_cloudwatch_logs_exports       = local.cloudwatch_logs_exports
  create_cloudwatch_log_group           = true

  maintenance_window = var.rds_maintenance_window
  backup_window      = var.rds_backup_window
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${local.rds_identifier}-sg"
  description = "${var.environment} ${var.environment} rds security group"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      description = "VPC RDS ${var.rds_engine} access"
      rule        = local.rds_sg_vpc_rule_name
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
}
# @section services.rds.enabled end

# @section services.aurora.enabled begin
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.13"

  name           = local.aurora_name
  database_name  = local.aurora_database_name
  engine         = var.aurora_engine
  engine_version = var.aurora_engine_version
  engine_mode    = "provisioned"
  instance_class = "db.serverless"

  instances = var.aurora_instances

  serverlessv2_scaling_configuration = {
    min_capacity             = var.aurora_serverlessv2_min_capacity
    max_capacity             = var.aurora_serverlessv2_max_capacity
    seconds_until_auto_pause = var.aurora_serverlessv2_seconds_until_auto_pause
  }

  vpc_id                 = module.vpc.vpc_id
  vpc_security_group_ids = [module.aurora_sg.security_group_id]
  subnets                = module.vpc.database_subnets
  create_db_subnet_group = true
  enable_http_endpoint   = var.aurora_enable_http_endpoint

  master_username             = local.aurora_username
  master_password             = random_password.aurora_password.result
  manage_master_user_password = false
  port                        = local.aurora_port

  storage_encrypted = true

  iam_database_authentication_enabled = var.aurora_iam_database_authentication_enabled

  create_monitoring_role          = true
  monitoring_interval             = var.aurora_monitoring_interval
  enabled_cloudwatch_logs_exports = local.cloudwatch_logs_exports
  create_cloudwatch_log_group     = true

  apply_immediately        = var.aurora_apply_immediately
  deletion_protection      = var.aurora_deletion_protection
  skip_final_snapshot      = var.aurora_skip_final_snapshot
  delete_automated_backups = var.aurora_delete_automated_backups
  backup_retention_period  = var.aurora_backup_retention_period
}

module "aurora_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${local.aurora_name}-sg"
  description = "${var.environment} ${var.environment} aurora security group"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      description = "VPC Aurora ${var.aurora_engine} access"
      rule        = local.aurora_sg_vpc_rule_name
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
}
# @section services.aurora.enabled end
