# -------------------------------------------------------------------
# GLOBAL
# -------------------------------------------------------------------

# @param name
global_prefix = "my-project"
# @param name
environment = "development"
# @param global.environment_short
environment_short = "dev"

# -------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------

# @param services.vpc.vpcCidr
vpc_cidr = "10.0.0.0/16"
# @param services.vpc.azCount
az_count = 2
# @param services.vpc.natGatewayStrategy
nat_gateway_strategy = "SINGLE"
# @param services.vpc.publicSubnetTags
public_subnet_tags = {}
# @param services.vpc.privateSubnetTags
private_subnet_tags = {}
# @param services.vpc.databaseSubnetTags
database_subnet_tags = {}

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

# @param services.eks.defaultNodeGroupAmiType
default_node_group_ami_type = "BOTTLEROCKET_ARM_64"
# @param services.eks.defaultNodeGroupInstanceType
default_node_group_instance_type = "t4g.large"

# -------------------------------------------------------------------
# KARPENTER
# -------------------------------------------------------------------

# @param karpenter.default_nodepool_arch
karpenter_nodepool_arch = "arm64"

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

# @param services.opensearch.customEndpointEnabled
opensearch_custom_endpoint_enabled = false
