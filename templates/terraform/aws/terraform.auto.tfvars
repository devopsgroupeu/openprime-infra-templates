# -------------------------------------------------------------------
# GLOBAL
# -------------------------------------------------------------------

# @param region
region = "eu-west-1"
# @param globalPrefix
global_prefix = "my-project"
# @param name
environment = "development"

# -------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------

# @module services.vpc | label=Virtual Private Cloud (VPC) | category=Networking | description=AWS Virtual Private Cloud for network isolation
# @param services.vpc.cidr | label=CIDR Block | description=The IPv4 CIDR block for the VPC | control=text
vpc_cidr = "10.0.0.0/16"
# @param services.vpc.azCount | label=Availability Zones | description=Number of availability zones to use for high availability | control=dropdown | options=[{"value":1,"label":"1 AZ (Development only)"},{"value":2,"label":"2 AZs (Recommended)"},{"value":3,"label":"3 AZs (High availability)"}]
az_count = 2
# @param services.vpc.createPublicSubnets | label=Public Subnets | description=Create public subnets with internet access | control=toggle
create_public_subnets = true
# @param services.vpc.createPrivateSubnets | label=Private Subnets | description=Create private subnets for internal resources | control=toggle
create_private_subnets = true
# @param services.vpc.createIntraSubnets | label=Intra Subnets | description=Create isolated subnets with no internet access | control=toggle
create_intra_subnets = false
# @param services.vpc.createDatabaseSubnets | label=Database Subnets | description=Create dedicated subnets for databases | control=toggle
create_database_subnets = true
# @param services.vpc.natGateway | label=NAT Gateway Strategy | description=How to provision NAT gateways for private subnet internet access | control=dropdown | options=[{"value":"NO_NAT","label":"None - No internet for private subnets"},{"value":"SINGLE","label":"Single - Cost-effective (not HA)"},{"value":"ONE_PER_AZ","label":"One per AZ - High availability (recommended)"},{"value":"ONE_PER_SUBNET","label":"One per subnet - Maximum redundancy"}]
nat_gateway_strategy = "SINGLE"
# @param services.vpc.publicSubnetTags | label=Public Subnet Tags | description=Additional AWS tags for public subnets (JSON) | control=object
public_subnet_tags = {}
# @param services.vpc.privateSubnetTags | label=Private Subnet Tags | description=Additional AWS tags for private subnets (JSON) | control=object
private_subnet_tags = {}
# @param services.vpc.databaseSubnetTags | label=Database Subnet Tags | description=Additional AWS tags for database subnets (JSON) | control=object
database_subnet_tags = {}
# @param services.vpc.enableDnsHostnames | label=DNS Hostnames | description=Enable DNS hostname resolution in VPC | control=toggle
enable_dns_hostnames = true
# @param services.vpc.enableDnsSupport | label=DNS Support | description=Enable DNS resolution in VPC | control=toggle
enable_dns_support = true
# @param services.vpc.createDatabaseSubnetGroup | label=DB Subnet Group | description=Create RDS/Aurora subnet group automatically | control=toggle
create_database_subnet_group = true
# @param services.vpc.enableVpnGateway | label=VPN Gateway | description=Enable VPN Gateway for hybrid cloud connectivity | control=toggle
enable_vpn_gateway = false
# @param services.vpc.enableFlowLogs | label=VPC Flow Logs | description=Enable flow logs for network traffic analysis | control=toggle
enable_flow_logs = false

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

# @module services.eks | label=Elastic Kubernetes Service (EKS) | category=Compute | description=Managed Kubernetes service from AWS
# @param services.eks.kubernetesVersion | label=Kubernetes Version | description=Kubernetes version | control=dropdown | options=[{"value":"1.30","label":"1.30"},{"value":"1.31","label":"1.31"},{"value":"1.32","label":"1.32"},{"value":"1.33","label":"1.33"},{"value":"1.34","label":"1.34"},{"value":"1.35","label":"1.35"}]
kubernetes_version = "1.33"
# @param services.eks.enableClusterCreatorAdminPermissions | label=Cluster Creator Admin | description=Enable cluster creator admin permissions | control=toggle
enable_cluster_creator_admin_permissions = true
# @param services.eks.endpointPublicAccess | label=Public Endpoint | description=Enable public access to cluster endpoint | control=toggle
endpoint_public_access = true
# @param services.eks.authenticationMode | label=Authentication Mode | description=Authentication mode for the cluster | control=dropdown | options=[{"value":"API","label":"API"},{"value":"API_AND_CONFIG_MAP","label":"API and ConfigMap"},{"value":"CONFIG_MAP","label":"ConfigMap"}]
authentication_mode = "API"
# @param services.eks.enableIrsa | label=IRSA | description=Enable IAM Roles for Service Accounts | control=toggle
enable_irsa = true

# @param services.eks.defaultNodeGroupAmiType | label=AMI Type | description=AMI type for node group | control=dropdown | options=[{"value":"AL2_x86_64","label":"Amazon Linux 2 (x86_64)"},{"value":"AL2_x86_64_GPU","label":"Amazon Linux 2 GPU (x86_64)"},{"value":"AL2_ARM_64","label":"Amazon Linux 2 (ARM64)"},{"value":"BOTTLEROCKET_ARM_64","label":"Bottlerocket (ARM64)"},{"value":"BOTTLEROCKET_x86_64","label":"Bottlerocket (x86_64)"}]
default_node_group_ami_type = "BOTTLEROCKET_ARM_64"
# @param services.eks.defaultNodeGroupInstanceTypes | label=Instance Types | description=EC2 instance types | control=multiselect | options=[{"value":"t3.micro","label":"t3.micro"},{"value":"t3.small","label":"t3.small"},{"value":"t3.medium","label":"t3.medium"},{"value":"t3.large","label":"t3.large"},{"value":"t4g.medium","label":"t4g.medium"},{"value":"t4g.large","label":"t4g.large"},{"value":"m5.large","label":"m5.large"},{"value":"m5.xlarge","label":"m5.xlarge"}]
default_node_group_instance_types = ["t4g.large"]
# @param services.eks.defaultNodeGroupCapacityType | label=Capacity Type | description=Capacity type for node group | control=dropdown | options=[{"value":"ON_DEMAND","label":"On-Demand"},{"value":"SPOT","label":"Spot"}]
default_node_group_capacity_type = "ON_DEMAND"
# @param services.eks.defaultNodeGroupMinSize | label=Min Nodes | description=Minimum number of nodes | control=number | min=0 | max=100
default_node_group_min_size = 1
# @param services.eks.defaultNodeGroupMaxSize | label=Max Nodes | description=Maximum number of nodes | control=number | min=1 | max=100
default_node_group_max_size = 10
# @param services.eks.defaultNodeGroupDesiredSize | label=Desired Nodes | description=Desired number of nodes | control=number | min=0 | max=100
default_node_group_desired_size = 2
# @param services.eks.defaultNodeGroupMaxUnavailable | label=Max Unavailable | description=Max unavailable nodes during updates | control=number | min=1 | max=10
default_node_group_max_unavailable = 1
# @param services.eks.defaultNodeGroupUseLatestAmi
default_node_group_use_latest_ami = true
# NOT parameterized (OP-221): Injecto rewrites only the single line following a
# decorator, so decorating this multi-line map would emit the new value and
# orphan the body plus its closing brace. Injecto now refuses that outright
# rather than corrupting the file, which makes a decorator here a promise it
# cannot keep. Re-add one only alongside multi-line substitution support.
# (Deliberately avoids writing the decorator keyword: the scanner matches it
# anywhere in a comment, so naming it here would declare a real decorator.)
default_node_group_iam_additional_policies = {
  AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# @param services.eks.addonCorednsMostRecent
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
# @param services.eks.karpenterNodepoolArch | label=Karpenter Architecture | description=Default Karpenter nodepool architecture | control=dropdown | options=[{"value":"amd64","label":"AMD64 (x86_64)"},{"value":"arm64","label":"ARM64"}]
karpenter_nodepool_arch = "arm64"
# @param services.eks.karpenterNodepoolCapacityType | label=Karpenter Capacity Type | description=Default Karpenter capacity type | control=dropdown | options=[{"value":"on-demand","label":"On-Demand"},{"value":"spot","label":"Spot"}]
karpenter_nodepool_capacity_type = "spot"

# -------------------------------------------------------------------
# MSK
# -------------------------------------------------------------------

# @module services.msk | label=Managed Streaming for Apache Kafka (MSK) | category=Integration | description=Fully managed Apache Kafka service for real-time streaming
# @param services.msk.kafkaVersion | label=Kafka Version | description=Apache Kafka version | control=dropdown | options=[{"value":"3.9.x","label":"3.9.x (Recommended)"},{"value":"3.8.x","label":"3.8.x"},{"value":"3.7.x","label":"3.7.x"},{"value":"3.6.0","label":"3.6.0"}]
msk_kafka_version = "3.9.x"
# @param services.msk.numberOfBrokerNodes | label=Number of Broker Nodes | description=Number of broker nodes across availability zones | control=number | min=2 | max=30
msk_number_of_broker_nodes = 2
# @param services.msk.brokerNodeInstanceType | label=Broker Instance Type | description=EC2 instance type for each broker | control=dropdown | options=[{"value":"kafka.t3.small","label":"kafka.t3.small - 2 vCPU, 2GB (Dev/Test)"},{"value":"kafka.m5.large","label":"kafka.m5.large - 2 vCPU, 8GB"},{"value":"kafka.m5.xlarge","label":"kafka.m5.xlarge - 4 vCPU, 16GB"},{"value":"kafka.m5.2xlarge","label":"kafka.m5.2xlarge - 8 vCPU, 32GB (Production)"}]
msk_broker_node_instance_type = "kafka.t3.small"

# -------------------------------------------------------------------
# DATABASE
# -------------------------------------------------------------------

# @module services.rds | label=Relational Database Service (RDS) | category=Database | description=Fully managed relational databases with automated backups
# @param services.rds.engine | label=Database Engine | description=Choose your database engine | control=dropdown | options=[{"value":"postgres","label":"PostgreSQL - Open-source, feature-rich"},{"value":"mysql","label":"MySQL - Popular open-source"},{"value":"mariadb","label":"MariaDB - MySQL fork"},{"value":"oracle-ee","label":"Oracle Enterprise"},{"value":"sqlserver-ex","label":"SQL Server Express"}]
rds_engine = "postgres"
# @param services.rds.version | label=Engine Version | description=Database version | control=text
rds_version = "15"
# @param services.rds.majorEngineVersion | label=Major Engine Version | description=Major version for parameter group | control=text
rds_major_engine_version = "15"
# @param services.rds.family | label=Parameter Group Family | description=DB parameter group family | control=text
rds_family = "postgres15"
# @param services.rds.instanceClass | label=Instance Class | description=Database compute capacity | control=dropdown | options=[{"value":"db.t3.micro","label":"t3.micro - 1 vCPU, 1GB (Dev)"},{"value":"db.t3.small","label":"t3.small - 2 vCPU, 2GB"},{"value":"db.t3.medium","label":"t3.medium - 2 vCPU, 4GB"},{"value":"db.t3.large","label":"t3.large - 2 vCPU, 8GB"},{"value":"db.r5.large","label":"r5.large - 2 vCPU, 16GB (Memory-optimized)"},{"value":"db.r5.xlarge","label":"r5.xlarge - 4 vCPU, 32GB"}]
rds_instance_class = "db.t3.micro"
# @param services.rds.allocatedStorage | label=Storage (GB) | description=Initial storage allocation | control=number | min=20 | max=1000
rds_allocated_storage = 20
# @param services.rds.maxAllocatedStorage | label=Max Storage (GB) | description=Maximum storage for auto-scaling | control=number | min=20 | max=10000
rds_max_allocated_storage = 50
# @param services.rds.multiAz | label=Multi-AZ Deployment | description=Deploy standby in another AZ | control=toggle
rds_multi_az = true
# @param services.rds.backupRetention | label=Backup Retention (days) | description=Automated backup retention | control=number | min=0 | max=35
rds_backup_retention_period = 7
# @param services.rds.backupWindow | label=Backup Window | description=Daily backup time window (UTC) | control=text
rds_backup_window = "03:00-06:00"
# @param services.rds.maintenanceWindow | label=Maintenance Window | description=Weekly maintenance window (UTC) | control=text
rds_maintenance_window = "Mon:00:00-Mon:03:00"
# @param services.rds.deletionProtection | label=Deletion Protection | description=Prevent accidental deletion | control=toggle
rds_deletion_protection = true
# @param services.rds.skipFinalSnapshot | label=Skip Final Snapshot | description=Skip snapshot on deletion | control=toggle
rds_skip_final_snapshot = false
# @param services.rds.applyImmediately | label=Apply Changes Immediately | description=Apply changes without waiting for maintenance | control=toggle
rds_apply_immediately = false
# @param services.rds.autoMinorVersionUpgrade | label=Auto Minor Version Upgrade | description=Auto-apply minor patches | control=toggle
rds_auto_minor_version_upgrade = true
# @param services.rds.publiclyAccessible | label=Publicly Accessible | description=Assign public IP address | control=toggle
rds_publicly_accessible = false
# @param services.rds.iamDatabaseAuthenticationEnabled | label=IAM Authentication | description=Enable IAM-based authentication | control=toggle
rds_iam_database_authentication_enabled = true
# @param services.rds.manageMasterUserPassword | label=AWS Managed Password | description=Store password in Secrets Manager | control=toggle
rds_manage_master_user_password = true
# @param services.rds.performanceInsights | label=Performance Insights | description=Database performance monitoring | control=toggle
rds_performance_insights_enabled = false
# @param services.rds.performanceInsightsRetentionPeriod | label=Insights Retention (days) | description=Performance data retention | control=number | min=7 | max=731
rds_performance_insights_retention_period = 7
# @param services.rds.monitoringInterval | label=Enhanced Monitoring (seconds) | description=OS metrics collection frequency | control=dropdown | options=[{"value":0,"label":"Disabled"},{"value":1,"label":"1 second (Most detailed)"},{"value":5,"label":"5 seconds"},{"value":10,"label":"10 seconds"},{"value":15,"label":"15 seconds"},{"value":30,"label":"30 seconds"},{"value":60,"label":"60 seconds (Recommended)"}]
rds_monitoring_interval = 60
# @param services.rds.deleteAutomatedBackups | label=Delete Automated Backups | description=Delete backups when instance is deleted | control=toggle
rds_delete_automated_backups = true

# @module services.aurora | label=Aurora Serverless | category=Database | description=Serverless relational database with auto-scaling
# @param services.aurora.engine | label=Database Engine | description=Aurora database engine | control=dropdown | options=[{"value":"aurora-postgresql","label":"Aurora PostgreSQL"},{"value":"aurora-mysql","label":"Aurora MySQL"}]
aurora_engine = "aurora-postgresql"
# @param services.aurora.engineVersion | label=Engine Version | description=Aurora engine version | control=text
aurora_engine_version = "15.10"
# @param services.aurora.instances | label=Aurora Instances | description=Map of Aurora instances configuration | control=object
aurora_instances = { one = {} }
# @param services.aurora.serverlessv2MinCapacity | label=Min Capacity (ACU) | description=Minimum Aurora Capacity Units | control=number | min=0 | max=128
aurora_serverlessv2_min_capacity = 0
# @param services.aurora.serverlessv2MaxCapacity | label=Max Capacity (ACU) | description=Maximum Aurora Capacity Units | control=number | min=0.5 | max=128
aurora_serverlessv2_max_capacity = 10
# @param services.aurora.serverlessv2SecondsUntilAutoPause | label=Seconds Until Auto Pause | description=Seconds until Aurora Serverless auto-pauses | control=number | min=300 | max=86400
aurora_serverlessv2_seconds_until_auto_pause = 3600
# @param services.aurora.backupRetention | label=Backup Retention (days) | description=Backup retention period in days | control=number | min=1 | max=35
aurora_backup_retention_period = 7
# @param services.aurora.deletionProtection | label=Deletion Protection | description=Enable deletion protection | control=toggle
aurora_deletion_protection = true
# @param services.aurora.enableHttpEndpoint | label=Data API | description=Enable HTTP endpoint for Data API | control=toggle
aurora_enable_http_endpoint = true
# @param services.aurora.iamDatabaseAuthenticationEnabled | label=IAM Database Authentication | description=Enable IAM database authentication | control=toggle
aurora_iam_database_authentication_enabled = true
# @param services.aurora.monitoringInterval | label=Enhanced Monitoring Interval (seconds) | description=Enhanced monitoring interval | control=dropdown | options=[{"value":0,"label":"Disabled"},{"value":1,"label":"1 second"},{"value":5,"label":"5 seconds"},{"value":10,"label":"10 seconds"},{"value":15,"label":"15 seconds"},{"value":30,"label":"30 seconds"},{"value":60,"label":"60 seconds"}]
aurora_monitoring_interval = 60
# @param services.aurora.applyImmediately | label=Apply Immediately | description=Apply changes immediately | control=toggle
aurora_apply_immediately = true
# @param services.aurora.skipFinalSnapshot | label=Skip Final Snapshot | description=Skip final snapshot when deleting | control=toggle
aurora_skip_final_snapshot = false
# @param services.aurora.manageMasterUserPassword | label=AWS Managed Password | description=Store password in Secrets Manager | control=toggle
aurora_manage_master_user_password = true
# @param services.aurora.deleteAutomatedBackups | label=Delete Automated Backups | description=Delete automated backups on cluster deletion | control=toggle
aurora_delete_automated_backups = true

# -------------------------------------------------------------------
# OpenSearch
# -------------------------------------------------------------------

# @module services.opensearch | label=OpenSearch Service | category=Database | description=Managed search and analytics service
# @param services.opensearch.domainName | label=Domain Name | description=OpenSearch domain name | control=text
opensearch_domain_name = "opensearch"
# @param services.opensearch.version | label=OpenSearch Version | description=OpenSearch version | control=dropdown | options=[{"value":"OpenSearch_2.19","label":"OpenSearch 2.19"},{"value":"OpenSearch_2.11","label":"OpenSearch 2.11"},{"value":"OpenSearch_2.9","label":"OpenSearch 2.9"},{"value":"OpenSearch_1.3","label":"OpenSearch 1.3"}]
opensearch_version = "OpenSearch_2.19"
# @param services.opensearch.instanceCount | label=Instance Count | description=Number of data instances | control=number | min=1 | max=20
opensearch_instance_count = 2
# @param services.opensearch.instanceType | label=Instance Type | description=OpenSearch instance type | control=dropdown | options=[{"value":"t3.small.search","label":"t3.small.search"},{"value":"t3.medium.search","label":"t3.medium.search"},{"value":"m5.large.search","label":"m5.large.search"},{"value":"m7g.medium.search","label":"m7g.medium.search"},{"value":"m7g.large.search","label":"m7g.large.search"}]
opensearch_instance_type = "m7g.medium.search"
# @param services.opensearch.ebsEnabled | label=EBS Storage | description=Enable EBS storage volumes | control=toggle
opensearch_ebs_enabled = true
# @param services.opensearch.ebsVolumeType | label=EBS Volume Type | description=EBS volume type | control=dropdown | options=[{"value":"gp3","label":"gp3"},{"value":"gp2","label":"gp2"},{"value":"io1","label":"io1"}]
opensearch_ebs_volume_type = "gp3"
# @param services.opensearch.ebsVolumeSize | label=EBS Volume Size (GB) | description=EBS volume size per instance | control=number | min=10 | max=1000
opensearch_ebs_volume_size = 64
# @param services.opensearch.customEndpointEnabled | label=Custom Endpoint | description=Enable custom endpoint | control=toggle
opensearch_custom_endpoint_enabled = false
# @param services.opensearch.masterUserName | label=Master User Name | description=Master user name for authentication | control=text
opensearch_master_user_name = "admin"
# @param services.opensearch.dedicatedMasterEnabled | label=Dedicated Master | description=Enable dedicated master nodes | control=toggle
opensearch_dedicated_master_enabled = false
# @param services.opensearch.dedicatedMasterType | label=Master Instance Type | description=Master node instance type | control=dropdown | options=[{"value":"t3.small.search","label":"t3.small.search"},{"value":"t3.medium.search","label":"t3.medium.search"},{"value":"m5.large.search","label":"m5.large.search"}]
opensearch_dedicated_master_type = "t3.small.search"
# @param services.opensearch.dedicatedMasterCount | label=Master Node Count | description=Number of master nodes | control=number | min=0 | max=5
opensearch_dedicated_master_count = 0
# @param services.opensearch.nodeToNodeEncryption | label=Node-to-Node Encryption | description=Enable node-to-node encryption | control=toggle
opensearch_node_to_node_encryption = true
# @param services.opensearch.enforceHttps | label=Enforce HTTPS | description=Enforce HTTPS for all traffic | control=toggle
opensearch_enforce_https = true
# @param services.opensearch.tlsSecurityPolicy | label=TLS Security Policy | description=TLS security policy | control=dropdown | options=[{"value":"Policy-Min-TLS-1-0-2019-07","label":"TLS 1.0 (Minimum)"},{"value":"Policy-Min-TLS-1-2-2019-07","label":"TLS 1.2 (Minimum)"},{"value":"Policy-Min-TLS-1-2-PFS-2023-10","label":"TLS 1.2 PFS"}]
opensearch_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
# @param services.opensearch.advancedSecurityEnabled | label=Advanced Security | description=Enable advanced security options | control=toggle
opensearch_advanced_security_enabled = true
# @param services.opensearch.internalUserDatabaseEnabled | label=Internal User Database | description=Enable internal user database | control=toggle
opensearch_internal_user_database_enabled = true
# @param services.opensearch.createAccessPolicy | label=Create Access Policy | description=Create domain access policy | control=toggle
opensearch_create_access_policy = true
# @param services.opensearch.ipAddressType | label=IP Address Type | description=IP address type for the domain | control=dropdown | options=[{"value":"ipv4","label":"IPv4 only"},{"value":"dualstack","label":"IPv4 and IPv6 (Dual Stack)"}]
opensearch_ip_address_type = "dualstack"
# @param services.opensearch.allowExplicitIndex | type=string | default=true | label=Allow Explicit Index | description=Allow explicit index in multi-action requests | control=toggle
opensearch_allow_explicit_index = "true"

# -------------------------------------------------------------------
# ELASTICACHE
# -------------------------------------------------------------------

# @module services.elasticache | label=ElastiCache | category=Database | description=Managed in-memory caching - Redis, Valkey, or Memcached
# @param services.elasticache.engine | label=Cache Engine | description=Choose your caching engine | control=dropdown | options=[{"value":"valkey","label":"Valkey - Open-source Redis alternative (recommended)"},{"value":"redis","label":"Redis - In-memory data store"},{"value":"memcached","label":"Memcached - Simple key-value cache"}]
elasticache_engine = "valkey"
# @param services.elasticache.engineVersion | label=Engine Version | description=Cache engine version | control=text
elasticache_engine_version = "7.2"
# @param services.elasticache.nodeType | label=Node Type | description=Instance type for cache nodes | control=dropdown | options=[{"value":"cache.t4g.micro","label":"t4g.micro - 0.5GB (Graviton, cost-effective)"},{"value":"cache.t4g.small","label":"t4g.small - 1.37GB (Graviton, recommended)"},{"value":"cache.t4g.medium","label":"t4g.medium - 3.09GB (Graviton)"},{"value":"cache.t3.micro","label":"t3.micro - 0.5GB (x86)"},{"value":"cache.t3.small","label":"t3.small - 1.37GB (x86)"},{"value":"cache.t3.medium","label":"t3.medium - 3.09GB (x86)"},{"value":"cache.r6g.large","label":"r6g.large - 13.07GB (Memory-optimized Graviton)"},{"value":"cache.r7g.large","label":"r7g.large - 13.07GB (Latest Graviton)"}]
elasticache_node_type = "cache.t4g.small"
# @param services.elasticache.numCacheNodes | label=Number of Cache Nodes | description=Number of cache nodes in the cluster | control=number | min=1 | max=20
elasticache_num_cache_nodes = 1
# @param services.elasticache.parameterGroupFamily | label=Parameter Group Family | description=Must match your engine and version | control=dropdown | options=[{"value":"valkey7","label":"valkey7"},{"value":"redis7","label":"redis7"},{"value":"redis6.x","label":"redis6.x"},{"value":"memcached1.6","label":"memcached1.6"}]
elasticache_parameter_group_family = "valkey7"
# @param services.elasticache.transitEncryption | label=Transit Encryption (TLS) | description=Encrypt data in transit | control=toggle
elasticache_transit_encryption_enabled = true
# @param services.elasticache.atRestEncryption | label=At-Rest Encryption | description=Encrypt data at rest | control=toggle
elasticache_at_rest_encryption_enabled = true
# @param services.elasticache.authTokenEnabled | label=Auth Token (Password) | description=Enable authentication token (Redis/Valkey AUTH) | control=toggle
elasticache_auth_token_enabled = true
# @param services.elasticache.maintenanceWindow | label=Maintenance Window | description=Preferred maintenance window (UTC) | control=text
elasticache_maintenance_window = "sun:05:00-sun:06:00"
# @param services.elasticache.snapshotRetentionLimit | label=Snapshot Retention Days | description=Number of days to retain automatic snapshots | control=number | min=0 | max=35
elasticache_snapshot_retention_limit = 7
# @param services.elasticache.snapshotWindow | label=Snapshot Window | description=Daily time range for automatic snapshots (UTC) | control=text
elasticache_snapshot_window = "03:00-05:00"
# @param services.elasticache.automaticFailover | label=Automatic Failover | description=Enable automatic failover to replica | control=toggle
elasticache_automatic_failover_enabled = false
# @param services.elasticache.multiAz | label=Multi-AZ Deployment | description=Deploy across multiple availability zones | control=toggle
elasticache_multi_az_enabled = false

# -------------------------------------------------------------------
# ECR
# -------------------------------------------------------------------

# @module services.ecr | label=Elastic Container Registry (ECR) | category=Storage | description=Managed Docker container registry with vulnerability scanning
# @param services.ecr.repositoryNames | type=list | label=Repository Names | description=List of ECR repository names to create | control=array
ecr_repository_names = []
# @param services.ecr.repositoryType | label=Repository Type | description=Repository visibility (applies to all repositories) | control=dropdown | options=[{"value":"private","label":"Private - Requires authentication"},{"value":"public","label":"Public - Accessible without authentication"}]
ecr_repository_type = "private"
# @param services.ecr.imageTagMutability | label=Image Tag Mutability | description=Prevent tag overwrites | control=dropdown | options=[{"value":"MUTABLE","label":"Mutable - Tags can be overwritten"},{"value":"IMMUTABLE","label":"Immutable - Tags cannot be overwritten"}]
ecr_image_tag_mutability = "IMMUTABLE"
# @param services.ecr.encryptionType | label=Encryption Type | description=Image encryption method | control=dropdown | options=[{"value":"AES256","label":"AES256 - AWS managed encryption"},{"value":"KMS","label":"KMS - Customer managed keys (additional cost)"}]
ecr_encryption_type = "AES256"
# @param services.ecr.enableScanning | label=Enable Vulnerability Scanning | description=Automatically scan images for vulnerabilities on push | control=toggle
ecr_enable_scanning = true
# @param services.ecr.scanType | label=Scan Type | description=Level of vulnerability scanning | control=dropdown | options=[{"value":"BASIC","label":"Basic - Standard CVE scanning (free)"},{"value":"ENHANCED","label":"Enhanced - AWS Inspector integration (charged)"}]
ecr_scan_type = "BASIC"
# @param services.ecr.createLifecyclePolicy | label=Enable Lifecycle Policy | description=Automatically cleanup old images to save storage costs | control=toggle
ecr_create_lifecycle_policy = true
# @param services.ecr.lifecyclePolicyMaxImages | label=Maximum Images to Keep | description=Number of images to retain per repository | control=number | min=1 | max=1000
ecr_lifecycle_policy_max_images = 25
# @param services.ecr.enableReplication | label=Enable Cross-Region Replication | description=Replicate images to other regions for disaster recovery | control=toggle
ecr_enable_replication = false
# @param services.ecr.replicationDestinations | type=list | label=Replication Destination Regions | description=List of AWS regions to replicate images to | control=array
ecr_replication_destinations = []

# -------------------------------------------------------------------
# WAF
# -------------------------------------------------------------------

# @module services.waf | label=Web Application Firewall (WAF) | category=Security | description=Protect web apps from common exploits and attacks
# @param services.waf.name | label=WAF Name | description=Name for the WAF Web ACL | control=text
waf_name = "waf"
# @param services.waf.description | label=Description | description=Description of the WAF configuration | control=text
waf_description = "Default AWS WAF Managed rule set"
# @param services.waf.scope | label=Scope | description=Where the WAF will be applied | control=dropdown | options=[{"value":"REGIONAL","label":"Regional - ALB, API Gateway, AppSync"},{"value":"CLOUDFRONT","label":"CloudFront - Global edge locations"}]
waf_scope = "REGIONAL"
# @param services.waf.cloudwatchMetricsEnabled | label=CloudWatch Metrics | description=Enable detailed metrics | control=toggle
waf_cloudwatch_metrics_enabled = true
# @param services.waf.metricName | label=Metric Name | description=Name for CloudWatch metrics | control=text
waf_metric_name = "WAF-metrics"
# @param services.waf.sampledRequestsEnabled | label=Sampled Requests | description=Store samples of blocked/allowed requests | control=toggle
waf_sampled_requests_enabled = true

# -------------------------------------------------------------------
# S3
# -------------------------------------------------------------------

# @module services.s3 | label=Simple Storage Service (S3) | category=Storage | description=Scalable object storage with 99.999999999% durability
# @param services.s3.bucketNames | type=list | label=Bucket Names | description=List of bucket names to create (one per line) | control=array
s3_bucket_names = []

# -------------------------------------------------------------------
# LAMBDA
# -------------------------------------------------------------------

# @module services.lambda | label=AWS Lambda | category=Compute | description=Serverless compute - run code without managing servers
# @param services.lambda.functionNames | type=list | label=Function Names | description=List of Lambda function names to create (one per line) | control=array
lambda_function_names = []

# -------------------------------------------------------------------
# SQS
# -------------------------------------------------------------------

# @module services.sqs | label=Simple Queue Service (SQS) | category=Integration | description=Managed message queuing for decoupled microservices
# @param services.sqs.queueNames | type=list | label=Queue Names | description=Queue names to create | control=array
sqs_queue_names = []
# @param services.sqs.fifoQueues | label=FIFO Queues | description=Enable First-In-First-Out ordering | control=toggle
sqs_fifo_queues = false
# @param services.sqs.contentBasedDeduplication | label=Content-Based Deduplication | description=Auto-deduplicate based on message content | control=toggle
sqs_content_based_deduplication = false
# @param services.sqs.visibilityTimeout | label=Visibility Timeout (seconds) | description=How long messages are invisible after being received | control=number | min=0 | max=43200
sqs_visibility_timeout = 30
# @param services.sqs.messageRetention | label=Message Retention (seconds) | description=How long to keep messages before deletion | control=number | min=60 | max=1209600
sqs_message_retention = 345600
# @param services.sqs.maxMessageSize | label=Max Message Size (bytes) | description=Maximum size per message | control=number | min=1024 | max=262144
sqs_max_message_size = 262144
# @param services.sqs.delaySeconds | label=Delivery Delay (seconds) | description=Delay before messages become available | control=number | min=0 | max=900
sqs_delay_seconds = 0
# @param services.sqs.receiveWaitTime | label=Receive Wait Time (seconds) | description=Long polling wait time | control=number | min=0 | max=20
sqs_receive_wait_time = 0
# @param services.sqs.createDeadLetterQueue | label=Dead Letter Queue | description=Capture failed messages for debugging | control=toggle
sqs_create_dlq = false
# @param services.sqs.maxReceiveCount | label=Max Receive Count | description=Attempts before moving to DLQ | control=number | min=1 | max=1000
sqs_max_receive_count = 3
# @param services.sqs.enableEncryption | label=Server-Side Encryption | description=Encrypt messages at rest | control=toggle
sqs_enable_encryption = true

# -------------------------------------------------------------------
# SNS
# -------------------------------------------------------------------

# @module services.sns | label=Simple Notification Service (SNS) | category=Integration | description=Pub/sub messaging for fan-out notifications to subscribers
# @param services.sns.topicNames | type=list | label=Topic Names | description=SNS topics to create | control=array
sns_topic_names = []
# @param services.sns.fifoTopics | label=FIFO Topics | description=Enable First-In-First-Out ordering | control=toggle
sns_fifo_topics = false
# @param services.sns.contentBasedDeduplication | label=Content-Based Deduplication | description=Auto-deduplicate based on message content | control=toggle
sns_content_based_deduplication = false
# @param services.sns.enableEncryption | label=Enable Encryption | description=Encrypt messages at rest | control=toggle
sns_enable_encryption = false
# @param services.sns.kmsKeyId | type=string | default= | label=KMS Key ID | description=KMS key for encryption | control=text
sns_kms_key_id = null

# -------------------------------------------------------------------
# CLOUDFRONT
# -------------------------------------------------------------------

# @module services.cloudfront | label=CloudFront | category=Networking | description=Global CDN for fast content delivery with edge caching
# @param services.cloudfront.distributionNames | type=list | label=Distribution Aliases | description=Custom domain names for distributions | control=array
cloudfront_distribution_names = []
# @param services.cloudfront.priceClass | label=Price Class | description=Edge location coverage (affects cost) | control=dropdown | options=[{"value":"PriceClass_100","label":"US, Canada, Europe (Lowest cost)"},{"value":"PriceClass_200","label":"+ Asia, Middle East, Africa"},{"value":"PriceClass_All","label":"All Edge Locations (Global)"}]
cloudfront_price_class = "PriceClass_100"
# @param services.cloudfront.enableIpv6 | label=Enable IPv6 | description=Support IPv6 client connections | control=toggle
cloudfront_enable_ipv6 = true
# @param services.cloudfront.enableWaf | label=WAF Integration | description=Attach AWS WAF for protection | control=toggle
cloudfront_enable_waf = false
# @param services.cloudfront.enableLogging | label=Access Logging | description=Log requests to S3 | control=toggle
cloudfront_enable_logging = false
# @param services.cloudfront.loggingBucket | type=string | default= | label=Logging Bucket | description=S3 bucket for access logs | control=text
cloudfront_logging_bucket = null

# -------------------------------------------------------------------
# ROUTE53
# -------------------------------------------------------------------

# @module services.route53 | label=Route 53 | category=Networking | description=Scalable DNS and domain management with health checks
# @param services.route53.zoneNames | type=list | label=Hosted Zone Domains | description=Domain names to manage | control=array
route53_zone_names = []
# @param services.route53.privateZones | label=Private Hosted Zones | description=Internal DNS for VPC resources | control=toggle
route53_private_zones = false
# @param services.route53.forceDestroy | label=Force Destroy | description=Allow zone deletion with records | control=toggle
route53_force_destroy = false
# @param services.route53.enableDnssec | label=Enable DNSSEC | description=Enable DNS Security Extensions | control=toggle
route53_enable_dnssec = false

# -------------------------------------------------------------------
# HELM CHARTS
# -------------------------------------------------------------------

# @param services.eks.helmCharts
helm_charts = {}
