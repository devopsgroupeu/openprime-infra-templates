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
# @param services.vpc.enableVpnGateway
enable_vpn_gateway = false
# @param services.vpc.enableFlowLogs
enable_flow_logs = false

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
# @param services.eks.karpenterNodepoolArch
karpenter_nodepool_arch = "arm64"
# @param services.eks.karpenterNodepoolCapacityType
karpenter_nodepool_capacity_type = "spot"

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
# @param services.rds.allocatedStorage
rds_allocated_storage = 20
# @param services.rds.maxAllocatedStorage
rds_max_allocated_storage = 50
# @param services.rds.multiAz
rds_multi_az = true
# @param services.rds.backupRetention
rds_backup_retention_period = 7
# @param services.rds.backupWindow
rds_backup_window = "03:00-06:00"
# @param services.rds.maintenanceWindow
rds_maintenance_window = "Mon:00:00-Mon:03:00"
# @param services.rds.deletionProtection
rds_deletion_protection = false
# @param services.rds.skipFinalSnapshot
rds_skip_final_snapshot = true
# @param services.rds.applyImmediately
rds_apply_immediately = false
# @param services.rds.autoMinorVersionUpgrade
rds_auto_minor_version_upgrade = true
# @param services.rds.publiclyAccessible
rds_publicly_accessible = false
# @param services.rds.iamDatabaseAuthenticationEnabled
rds_iam_database_authentication_enabled = true
# @param services.rds.manageMasterUserPassword
rds_manage_master_user_password = false
# @param services.rds.performanceInsights
rds_performance_insights_enabled = false
# @param services.rds.performanceInsightsRetentionPeriod
rds_performance_insights_retention_period = 7
# @param services.rds.monitoringInterval
rds_monitoring_interval = 60
# @param services.rds.deleteAutomatedBackups
rds_delete_automated_backups = true

# @param services.aurora.engine
aurora_engine = "aurora-postgresql"
# @param services.aurora.engineVersion
aurora_engine_version = "15.8"
# @param services.aurora.instances
aurora_instances = { one = {} }
# @param services.aurora.serverlessv2MinCapacity
aurora_serverlessv2_min_capacity = 0
# @param services.aurora.serverlessv2MaxCapacity
aurora_serverlessv2_max_capacity = 10
# @param services.aurora.serverlessv2SecondsUntilAutoPause
aurora_serverlessv2_seconds_until_auto_pause = 3600
# @param services.aurora.backupRetention
aurora_backup_retention_period = 7
# @param services.aurora.deletionProtection
aurora_deletion_protection = false
# @param services.aurora.enableHttpEndpoint
aurora_enable_http_endpoint = true
# @param services.aurora.iamDatabaseAuthenticationEnabled
aurora_iam_database_authentication_enabled = true
# @param services.aurora.monitoringInterval
aurora_monitoring_interval = 60
# @param services.aurora.applyImmediately
aurora_apply_immediately = true
# @param services.aurora.skipFinalSnapshot
aurora_skip_final_snapshot = true
# @param services.aurora.deleteAutomatedBackups
aurora_delete_automated_backups = true

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
# @param services.opensearch.dedicatedMasterEnabled
opensearch_dedicated_master_enabled = false
# @param services.opensearch.dedicatedMasterType
opensearch_dedicated_master_type = "t3.small.search"
# @param services.opensearch.dedicatedMasterCount
opensearch_dedicated_master_count = 0
# @param services.opensearch.nodeToNodeEncryption
opensearch_node_to_node_encryption = true
# @param services.opensearch.enforceHttps
opensearch_enforce_https = true
# @param services.opensearch.tlsSecurityPolicy
opensearch_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
# @param services.opensearch.advancedSecurityEnabled
opensearch_advanced_security_enabled = true
# @param services.opensearch.internalUserDatabaseEnabled
opensearch_internal_user_database_enabled = true
# @param services.opensearch.createAccessPolicy
opensearch_create_access_policy = true
# @param services.opensearch.ipAddressType
opensearch_ip_address_type = "dualstack"
# @param services.opensearch.allowExplicitIndex
opensearch_allow_explicit_index = "true"

# -------------------------------------------------------------------
# ECR
# -------------------------------------------------------------------

# @param services.ecr.repositories
ecr_repositories = []
# @param services.ecr.repositoryType
ecr_repository_type = "private"
# @param services.ecr.imageTagMutability
ecr_image_tag_mutability = "IMMUTABLE"
# @param services.ecr.repositoryEncryptionType
ecr_repository_encryption_type = "AES256"
# @param services.ecr.repositoryReadWriteAccessArns
ecr_repository_read_write_access_arns = []
# @param services.ecr.createLifecyclePolicy
ecr_create_lifecycle_policy = true
# @param services.ecr.lifecyclePolicyRulePriority
ecr_lifecycle_policy_rule_priority = 1
# @param services.ecr.lifecyclePolicyDescription
ecr_lifecycle_policy_description = "Keep last 25 images"
# @param services.ecr.lifecyclePolicyTagStatus
ecr_lifecycle_policy_tag_status = "tagged"
# @param services.ecr.lifecyclePolicyTagPrefixList
ecr_lifecycle_policy_tag_prefix_list = ["v"]
# @param services.ecr.lifecyclePolicyCountType
ecr_lifecycle_policy_count_type = "imageCountMoreThan"
# @param services.ecr.lifecyclePolicyCountNumber
ecr_lifecycle_policy_count_number = 25
# @param services.ecr.lifecyclePolicyActionType
ecr_lifecycle_policy_action_type = "expire"
# @param services.ecr.enableScanning
ecr_enable_scanning = true
# @param services.ecr.scanType
ecr_scan_type = "BASIC"
# @param services.ecr.enableReplication
ecr_enable_replication = false
# @param services.ecr.replicationDestinations
ecr_replication_destinations = []

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

# -------------------------------------------------------------------
# S3
# -------------------------------------------------------------------

# @param services.s3.bucketNames
s3_bucket_names = []
# @param services.s3.versioningEnabled
s3_versioning_enabled = false
# @param services.s3.encryptionType
s3_encryption_type = "AES256"
# @param services.s3.blockPublicAccess
s3_block_public_access = true
# @param services.s3.loggingEnabled
s3_logging_enabled = false
# @param services.s3.loggingTargetBucket
s3_logging_target_bucket = null
# @param services.s3.objectOwnership
s3_object_ownership = "BucketOwnerEnforced"

# -------------------------------------------------------------------
# LAMBDA
# -------------------------------------------------------------------

# @param services.lambda.functionNames
lambda_function_names = []
# @param services.lambda.defaultRuntime
lambda_default_runtime = "nodejs18.x"
# @param services.lambda.defaultMemory
lambda_default_memory = 256
# @param services.lambda.defaultTimeout
lambda_default_timeout = 30
# @param services.lambda.defaultHandler
lambda_default_handler = "index.handler"
# @param services.lambda.ephemeralStorageSize
lambda_ephemeral_storage_size = 512
# @param services.lambda.logRetentionDays
lambda_log_retention_days = 7
# @param services.lambda.enableVpc
lambda_enable_vpc = false
# @param services.lambda.enableXrayTracing
lambda_enable_xray_tracing = false

# -------------------------------------------------------------------
# SQS
# -------------------------------------------------------------------

# @param services.sqs.queueNames
sqs_queue_names = []
# @param services.sqs.fifoQueues
sqs_fifo_queues = false
# @param services.sqs.contentBasedDeduplication
sqs_content_based_deduplication = false
# @param services.sqs.visibilityTimeout
sqs_visibility_timeout = 30
# @param services.sqs.messageRetention
sqs_message_retention = 345600
# @param services.sqs.maxMessageSize
sqs_max_message_size = 262144
# @param services.sqs.delaySeconds
sqs_delay_seconds = 0
# @param services.sqs.receiveWaitTime
sqs_receive_wait_time = 0
# @param services.sqs.createDeadLetterQueue
sqs_create_dlq = false
# @param services.sqs.maxReceiveCount
sqs_max_receive_count = 3
# @param services.sqs.enableEncryption
sqs_enable_encryption = true

# -------------------------------------------------------------------
# SNS
# -------------------------------------------------------------------

# @param services.sns.topicNames
sns_topic_names = []
# @param services.sns.fifoTopics
sns_fifo_topics = false
# @param services.sns.contentBasedDeduplication
sns_content_based_deduplication = false
# @param services.sns.enableEncryption
sns_enable_encryption = false
# @param services.sns.kmsKeyId
sns_kms_key_id = null

# -------------------------------------------------------------------
# CLOUDFRONT
# -------------------------------------------------------------------

# @param services.cloudfront.distributionNames
cloudfront_distribution_names = []
# @param services.cloudfront.priceClass
cloudfront_price_class = "PriceClass_100"
# @param services.cloudfront.enableIpv6
cloudfront_enable_ipv6 = true
# @param services.cloudfront.enableWaf
cloudfront_enable_waf = false
# @param services.cloudfront.enableLogging
cloudfront_enable_logging = false
# @param services.cloudfront.loggingBucket
cloudfront_logging_bucket = null

# -------------------------------------------------------------------
# ROUTE53
# -------------------------------------------------------------------

# @param services.route53.zoneNames
route53_zone_names = []
# @param services.route53.privateZones
route53_private_zones = false
# @param services.route53.forceDestroy
route53_force_destroy = false
# @param services.route53.enableDnssec
route53_enable_dnssec = false
