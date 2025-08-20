locals {
  # @section rds begin
  rds_identifier          = "${var.global_prefix}rds-${var.environment_short}"
  rds_db_name             = "${var.global_prefix}db${var.environment_short}"
  rds_username            = "${var.global_prefix}rdsuser${var.environment_short}"
  rds_sg_vpc_rule_name    = var.rds_engine == "postgres" ? "postgresql-tcp" : "mysql-tcp"
  rds_port                = var.rds_engine == "postgres" ? 5432 : 3306
  cloudwatch_logs_exports = var.rds_engine == "postgres" ? ["postgresql"] : ["error", "general", "slowquery"]
  # @section rds end

  # @section aurora begin
  aurora_name             = "${var.global_prefix}auroradb${var.environment_short}"
  aurora_database_name    = "${var.global_prefix}auroradb${var.environment_short}"
  aurora_username         = "${var.global_prefix}aurorauser${var.environment_short}"
  aurora_sg_vpc_rule_name = var.aurora_engine == "aurora-postgresql" ? "postgresql-tcp" : "mysql-tcp"
  aurora_port             = var.aurora_engine == "aurora-postgresql" ? 5432 : 3306
  # @section aurora end
}

# @section rds begin
resource "random_password" "rds_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
# @section rds end

# @section aurora begin
resource "random_password" "aurora_password" {
  length  = 16
  upper   = true
  lower   = true
  numeric = true
  special = false
}
# @section aurora end

# @section rds begin
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.12"

  identifier = local.rds_identifier

  subnet_ids             = module.vpc.database_subnets
  create_db_subnet_group = true
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  apply_immediately         = false
  deletion_protection       = false
  skip_final_snapshot       = true
  create_db_option_group    = true
  create_db_parameter_group = true
  delete_automated_backups  = true
  backup_retention_period   = 7

  engine                     = var.rds_engine
  engine_version             = var.rds_engine_version
  major_engine_version       = var.rds_major_engine_version
  family                     = var.rds_family
  instance_class             = var.rds_instance_class
  multi_az                   = true
  auto_minor_version_upgrade = true

  db_name                     = local.rds_db_name
  manage_master_user_password = false
  username                    = local.rds_username
  password                    = random_password.rds_password.result
  port                        = local.rds_port

  storage_encrypted     = true
  allocated_storage     = 20
  max_allocated_storage = 50

  iam_database_authentication_enabled = true
  # publicly_accessible                 = true

  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  create_monitoring_role          = true
  monitoring_interval             = 60
  enabled_cloudwatch_logs_exports = local.cloudwatch_logs_exports
  create_cloudwatch_log_group     = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
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
# @section rds end

# @section aurora begin
module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.13"

  name           = local.aurora_name
  database_name  = local.aurora_database_name
  engine         = var.aurora_engine
  engine_version = var.aurora_engine_version
  engine_mode    = "provisioned"
  instance_class = "db.serverless"

  instances = {
    one = {}
  }

  serverlessv2_scaling_configuration = {
    min_capacity             = 0
    max_capacity             = 10
    seconds_until_auto_pause = 3600
  }

  vpc_id                 = module.vpc.vpc_id
  vpc_security_group_ids = [module.aurora_sg.security_group_id]
  subnets                = module.vpc.database_subnets
  create_db_subnet_group = true
  enable_http_endpoint   = true

  master_username             = local.aurora_username
  master_password             = random_password.aurora_password.result
  manage_master_user_password = false
  port                        = local.aurora_port

  storage_encrypted = true

  iam_database_authentication_enabled = true

  create_monitoring_role          = true
  monitoring_interval             = 60
  enabled_cloudwatch_logs_exports = local.cloudwatch_logs_exports
  create_cloudwatch_log_group     = true

  # DEV
  apply_immediately        = true
  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true
  # backup_retention_period  = 7
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
# @section aurora end