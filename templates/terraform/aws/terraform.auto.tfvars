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

# @param services.vpc.cidr
vpc_cidr = "10.0.0.0/16"
# @param services.vpc.azCount
az_count = 2
# @param services.vpc.createPublicSubnets
create_public_subnets = true
# @param services.vpc.createPrivateSubnets
create_private_subnets = true
# @param services.vpc.createIntraSubnets
create_intra_subnets = false
# @param services.vpc.createDatabaseSubnets
create_database_subnets = false
# @param services.vpc.natGateway
nat_gateway_strategy = "SINGLE"
# @param services.vpc.publicSubnetTags
public_subnet_tags = {}
# @param services.vpc.privateSubnetTags
private_subnet_tags = {}
# @param services.vpc.databaseSubnetTags
database_subnet_tags = {}
# @param services.vpc.enableDnsHostnames
enable_dns_hostnames = true
# @param services.vpc.enableDnsSupport
enable_dns_support = true
# @param services.vpc.createDatabaseSubnetGroup
create_database_subnet_group = true

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

# @param services.eks.kubernetesVersion
kubernetes_version = "1.33"
# @param services.eks.enableClusterCreatorAdminPermissions
enable_cluster_creator_admin_permissions = true
# @param services.eks.endpointPublicAccess
endpoint_public_access = true
# @param services.eks.authenticationMode
authentication_mode = "API"
# @param services.eks.enableIrsa
enable_irsa = true

# @param services.eks.defaultNodeGroupAmiType
default_node_group_ami_type = "BOTTLEROCKET_ARM_64"
# @param services.eks.defaultNodeGroupInstanceTypes
default_node_group_instance_types = ["t4g.large"]
# @param services.eks.defaultNodeGroupCapacityType
default_node_group_capacity_type = "ON_DEMAND"
# @param services.eks.defaultNodeGroupMinSize
default_node_group_min_size = 1
# @param services.eks.defaultNodeGroupMaxSize
default_node_group_max_size = 10
# @param services.eks.defaultNodeGroupDesiredSize
default_node_group_desired_size = 2
# @param services.eks.defaultNodeGroupMaxUnavailable
default_node_group_max_unavailable = 1
# @param services.eks.defaultNodeGroupUseLatestAmi
default_node_group_use_latest_ami = true
# @param services.eks.defaultNodeGroupIamAdditionalPolicies
default_node_group_iam_additional_policies = {
  AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# @param services.eks.addonCoredns MostRecent
eks_addon_coredns_most_recent = true
# @param services.eks.addonPodIdentityMostRecent
eks_addon_pod_identity_most_recent = true
# @param services.eks.addonPodIdentityBeforeCompute
eks_addon_pod_identity_before_compute = true
# @param services.eks.addonKubeProxyMostRecent
eks_addon_kube_proxy_most_recent = true
# @param services.eks.addonVpcCniMostRecent
eks_addon_vpc_cni_most_recent = true
# @param services.eks.addonVpcCniBeforeCompute
eks_addon_vpc_cni_before_compute = true
# @param services.eks.addonEbsCsiMostRecent
eks_addon_ebs_csi_most_recent = true
# @param services.eks.addonEfsCsiMostRecent
eks_addon_efs_csi_most_recent = true

# -------------------------------------------------------------------
# KARPENTER
# -------------------------------------------------------------------

# @param karpenter.defaultNodepoolArch
karpenter_nodepool_arch = "arm64"
# @param karpenter.defaultNodepoolCapacityType
karpenter_nodepool_capacity_type = "spot"
# @param karpenter.nodeIamRoleUseNamePrefix
karpenter_node_iam_role_use_name_prefix = false
# @param karpenter.createPodIdentityAssociation
karpenter_create_pod_identity_association = true
# @param karpenter.nodeIamRoleAdditionalPolicies
karpenter_node_iam_role_additional_policies = {
  AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -------------------------------------------------------------------
# MSK
# -------------------------------------------------------------------

# @param services.msk.kafkaVersion
msk_kafka_version = "3.5.1"
# @param services.msk.numberOfBrokerNodes
msk_number_of_broker_nodes = 2
# @param services.msk.brokerNodeInstanceType
msk_broker_node_instance_type = "kafka.t3.small"

# -------------------------------------------------------------------
# DATABASE
# -------------------------------------------------------------------

# @param services.rds.engine
rds_engine = "postgres"
# @param services.rds.engineVersion
rds_engine_version = "15"
# @param services.rds.majorEngineVersion
rds_major_engine_version = "15"
# @param services.rds.family
rds_family = "postgres15"
# @param services.rds.instanceClass
rds_instance_class = "db.t3.micro"

# @param services.aurora.engine
aurora_engine = "aurora-postgresql"
# @param services.aurora.engineVersion
aurora_engine_version = "15.8"

# -------------------------------------------------------------------
# OpenSearch
# -------------------------------------------------------------------

# @param services.opensearch.domainName
opensearch_domain_name = "opensearch"
# @param services.opensearch.version
opensearch_version = "OpenSearch_2.19"
# @param services.opensearch.instanceCount
opensearch_instance_count = 3
# @param services.opensearch.instanceType
opensearch_instance_type = "m7g.medium.search"
# @param services.opensearch.ebsEnabled
opensearch_ebs_enabled = true
# @param services.opensearch.ebsVolumeType
opensearch_ebs_volume_type = "gp3"
# @param services.opensearch.ebsVolumeSize
opensearch_ebs_volume_size = 64
# @param services.opensearch.customEndpointEnabled
opensearch_custom_endpoint_enabled = false
# @param services.opensearch.masterUserName
opensearch_master_user_name = "admin"

# -------------------------------------------------------------------
# ECR
# -------------------------------------------------------------------

# @param services.ecr.repositories
ecr_repositories = ["example-app"]
# @param services.ecr.repositoryType
ecr_repository_type = "private"
# @param services.ecr.imageTagMutability
ecr_image_tag_mutability = "IMMUTABLE"
# @param services.ecr.createLifecyclePolicy
ecr_create_lifecycle_policy = true
# @param services.ecr.enableScanning
ecr_enable_scanning = true
# @param services.ecr.scanType
ecr_scan_type = "BASIC"
# @param services.ecr.enableReplication
ecr_enable_replication = false
# @param services.ecr.replicationDestinations
ecr_replication_destinations = []
# @param services.ecr.repositoryEncryptionType
ecr_repository_encryption_type = "AES256"

# -------------------------------------------------------------------
# WAF
# -------------------------------------------------------------------

# @param services.waf.name
waf_name = "waf"
# @param services.waf.description
waf_description = "Default AWS WAF Managed rule set"
# @param services.waf.scope
waf_scope = "REGIONAL"
# @param services.waf.cloudwatchMetricsEnabled
waf_cloudwatch_metrics_enabled = true
# @param services.waf.metricName
waf_metric_name = "WAF-metrics"
# @param services.waf.sampledRequestsEnabled
waf_sampled_requests_enabled = true
