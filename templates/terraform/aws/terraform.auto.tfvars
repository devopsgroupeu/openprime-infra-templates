# -------------------------------------------------------------------
# GLOBAL
# -------------------------------------------------------------------

# @param global.global_prefix
global_prefix = "my-project"
# @param global.environment
environment = "development"
# @param global.environment_short
environment_short = "dev"

# -------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------

# @param vpc.vpc_cidr
vpc_cidr = "10.0.0.0/16"
# @param vpc.az_count
az_count = 2
# @param vpc.nat_gateway_strategy
nat_gateway_strategy = "SINGLE"
# @param vpc.public_subnet_tags
public_subnet_tags = {}
# @param vpc.private_subnet_tags
private_subnet_tags = {}
# @param vpc.database_subnet_tags
database_subnet_tags = {}

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

# @param eks.default_node_group_ami_type
default_node_group_ami_type = "BOTTLEROCKET_x86_64"
# @param eks.default_node_group_instance_type
default_node_group_instance_type = "m5.large"

# -------------------------------------------------------------------
# KARPENTER
# -------------------------------------------------------------------

# @param karpenter.default_nodepool_arch
karpenter_nodepool_arch = "amd64"

# -------------------------------------------------------------------
# DATABASE
# -------------------------------------------------------------------

rds_engine               = "postgres"
rds_engine_version       = "15"
rds_major_engine_version = "15"
rds_family               = "postgres15"

aurora_engine         = "aurora-postgresql"
aurora_engine_version = "15.8"

# -------------------------------------------------------------------
# OpenSearch
# -------------------------------------------------------------------

# @param opensearch.custom_endpoint_enabled
opensearch_custom_endpoint_enabled = false
