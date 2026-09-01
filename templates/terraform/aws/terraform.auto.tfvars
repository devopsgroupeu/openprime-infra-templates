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

# @module services.vpc | displayName=Virtual Private Cloud (VPC) | category=Networking | description=AWS Virtual Private Cloud for network isolation
# @param services.vpc.cidr | displayName=CIDR Block | description=The IPv4 CIDR block for the VPC | type=text | pattern=^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$
vpc_cidr = "10.0.0.0/16"
# @param services.vpc.azCount | displayName=Availability Zones | description=Number of availability zones to use for high availability | type=dropdown | options=[{"value":1,"label":"1 AZ (Development only)"},{"value":2,"label":"2 AZs (Recommended)"},{"value":3,"label":"3 AZs (High availability)"}]
az_count = 2
# @param services.vpc.createPublicSubnets | displayName=Public Subnets | description=Create public subnets with internet access | type=toggle
create_public_subnets = true
# @param services.vpc.createPrivateSubnets | displayName=Private Subnets | description=Create private subnets for internal resources | type=toggle
create_private_subnets = true
# @param services.vpc.createIntraSubnets | displayName=Intra Subnets | description=Create isolated subnets with no internet access | type=toggle
create_intra_subnets = false
# @param services.vpc.createDatabaseSubnets | displayName=Database Subnets | description=Create dedicated subnets for databases | type=toggle
create_database_subnets = true
# @param services.vpc.natGateway | displayName=NAT Gateway Strategy | description=How to provision NAT gateways for private subnet internet access | type=dropdown | options=[{"value":"NO_NAT","label":"None - No internet for private subnets"},{"value":"SINGLE","label":"Single - Cost-effective (not HA)"},{"value":"ONE_PER_AZ","label":"One per AZ - High availability (recommended)"},{"value":"ONE_PER_SUBNET","label":"One per subnet - Maximum redundancy"}]
nat_gateway_strategy = "SINGLE"
# @param services.vpc.publicSubnetTags | displayName=Public Subnet Tags | description=Additional AWS tags for public subnets (JSON) | type=object
public_subnet_tags = {}
# @param services.vpc.privateSubnetTags | displayName=Private Subnet Tags | description=Additional AWS tags for private subnets (JSON) | type=object
private_subnet_tags = {}
# @param services.vpc.databaseSubnetTags | displayName=Database Subnet Tags | description=Additional AWS tags for database subnets (JSON) | type=object
database_subnet_tags = {}
# @param services.vpc.enableDnsHostnames | displayName=DNS Hostnames | description=Enable DNS hostname resolution in VPC | type=toggle
enable_dns_hostnames = true
# @param services.vpc.enableDnsSupport | displayName=DNS Support | description=Enable DNS resolution in VPC | type=toggle
enable_dns_support = true
# @param services.vpc.createDatabaseSubnetGroup | displayName=DB Subnet Group | description=Create RDS/Aurora subnet group automatically | type=toggle
create_database_subnet_group = true
# @param services.vpc.enableVpnGateway | displayName=VPN Gateway | description=Enable VPN Gateway for hybrid cloud connectivity | type=toggle
enable_vpn_gateway = false
# @param services.vpc.enableFlowLogs | displayName=VPC Flow Logs | description=Enable flow logs for network traffic analysis | type=toggle
enable_flow_logs = false

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

# @module services.eks | displayName=Elastic Kubernetes Service (EKS) | category=Compute | description=Managed Kubernetes service from AWS
# @param services.eks.kubernetesVersion | displayName=Kubernetes Version | description=Kubernetes version | type=dropdown | options=[{"value":"1.34","label":"1.34"},{"value":"1.35","label":"1.35"},{"value":"1.36","label":"1.36"}]
kubernetes_version = "1.36"
# @param services.eks.enableClusterCreatorAdminPermissions | displayName=Cluster Creator Admin | description=Enable cluster creator admin permissions | type=toggle
enable_cluster_creator_admin_permissions = true
# @param services.eks.endpointPublicAccess | displayName=Public Endpoint | description=Enable public access to cluster endpoint | type=toggle
endpoint_public_access = true
# @param services.eks.authenticationMode | displayName=Authentication Mode | description=Authentication mode for the cluster | type=dropdown | options=[{"value":"API","label":"API"},{"value":"API_AND_CONFIG_MAP","label":"API and ConfigMap"},{"value":"CONFIG_MAP","label":"ConfigMap"}]
authentication_mode = "API"
# @param services.eks.enableIrsa | displayName=IRSA | description=Enable IAM Roles for Service Accounts | type=toggle
enable_irsa = true

# @param services.eks.defaultNodeGroupAmiType | displayName=AMI Type | description=AMI type for node group | type=dropdown | options=[{"value":"AL2_x86_64","label":"Amazon Linux 2 (x86_64)"},{"value":"AL2_x86_64_GPU","label":"Amazon Linux 2 GPU (x86_64)"},{"value":"AL2_ARM_64","label":"Amazon Linux 2 (ARM64)"},{"value":"BOTTLEROCKET_ARM_64","label":"Bottlerocket (ARM64)"},{"value":"BOTTLEROCKET_x86_64","label":"Bottlerocket (x86_64)"}]
default_node_group_ami_type = "BOTTLEROCKET_ARM_64"
# @param services.eks.defaultNodeGroupInstanceTypes | displayName=Instance Types | description=EC2 instance types | type=multiselect | options=[{"value":"t3.micro","label":"t3.micro"},{"value":"t3.small","label":"t3.small"},{"value":"t3.medium","label":"t3.medium"},{"value":"t3.large","label":"t3.large"},{"value":"t4g.medium","label":"t4g.medium"},{"value":"t4g.large","label":"t4g.large"},{"value":"m5.large","label":"m5.large"},{"value":"m5.xlarge","label":"m5.xlarge"}]
default_node_group_instance_types = ["t4g.large"]
# @param services.eks.defaultNodeGroupCapacityType | displayName=Capacity Type | description=Capacity type for node group | type=dropdown | options=[{"value":"ON_DEMAND","label":"On-Demand"},{"value":"SPOT","label":"Spot"}]
default_node_group_capacity_type = "ON_DEMAND"
# @param services.eks.defaultNodeGroupMinSize | displayName=Min Nodes | description=Minimum number of nodes | type=number | min=0 | max=100
default_node_group_min_size = 1
# @param services.eks.defaultNodeGroupMaxSize | displayName=Max Nodes | description=Maximum number of nodes | type=number | min=1 | max=100
default_node_group_max_size = 10
# @param services.eks.defaultNodeGroupDesiredSize | displayName=Desired Nodes | description=Desired number of nodes | type=number | min=0 | max=100
default_node_group_desired_size = 2
# @param services.eks.defaultNodeGroupMaxUnavailable | displayName=Max Unavailable | description=Max unavailable nodes during updates | type=number | min=1 | max=10
default_node_group_max_unavailable = 1
# @param services.eks.defaultNodeGroupUseLatestAmi | displayName=Use Latest Node AMI | description=Launch node groups on the newest AMI Amazon publishes for the cluster version | type=toggle
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

# @param services.eks.addonCorednsMostRecent | displayName=CoreDNS: Latest Version | description=Install the most recent CoreDNS addon rather than the cluster default | type=toggle
eks_addon_coredns_most_recent = true
# @param services.eks.addonPodIdentityMostRecent | displayName=Pod Identity: Latest Version | description=Install the most recent Pod Identity Agent addon | type=toggle
eks_addon_pod_identity_most_recent = true
# @param services.eks.addonPodIdentityBeforeCompute | displayName=Pod Identity Before Compute | description=Install the Pod Identity Agent before nodes join, so workloads can assume roles from the first boot | type=toggle
eks_addon_pod_identity_before_compute = true
# @param services.eks.addonKubeProxyMostRecent | displayName=kube-proxy: Latest Version | description=Install the most recent kube-proxy addon | type=toggle
eks_addon_kube_proxy_most_recent = true
# @param services.eks.addonVpcCniMostRecent | displayName=VPC CNI: Latest Version | description=Install the most recent VPC CNI addon | type=toggle
eks_addon_vpc_cni_most_recent = true
# @param services.eks.addonVpcCniBeforeCompute | displayName=VPC CNI Before Compute | description=Install the VPC CNI before nodes join; without it the first nodes can come up without pod networking | type=toggle
eks_addon_vpc_cni_before_compute = true
# @param services.eks.addonEbsCsiMostRecent | displayName=EBS CSI: Latest Version | description=Install the most recent EBS CSI driver addon | type=toggle
eks_addon_ebs_csi_most_recent = true
# @param services.eks.addonEfsCsiMostRecent | displayName=EFS CSI: Latest Version | description=Install the most recent EFS CSI driver addon | type=toggle
eks_addon_efs_csi_most_recent = true
# @param services.eks.karpenterNodepoolArch | displayName=Karpenter Architecture | description=Default Karpenter nodepool architecture | type=dropdown | options=[{"value":"amd64","label":"AMD64 (x86_64)"},{"value":"arm64","label":"ARM64"}]
karpenter_nodepool_arch = "arm64"
# @param services.eks.karpenterNodepoolCapacityType | displayName=Karpenter Capacity Type | description=Default Karpenter capacity type | type=dropdown | options=[{"value":"on-demand","label":"On-Demand"},{"value":"spot","label":"Spot"}]
karpenter_nodepool_capacity_type = "spot"

# -------------------------------------------------------------------
# MSK
# -------------------------------------------------------------------

# @module services.msk | displayName=Managed Streaming for Apache Kafka (MSK) | category=Integration | description=Fully managed Apache Kafka service for real-time streaming
# @param services.msk.kafkaVersion | displayName=Kafka Version | description=Apache Kafka version | type=dropdown | options=[{"value":"3.9.x","label":"3.9.x (Recommended)"},{"value":"3.8.x","label":"3.8.x"},{"value":"3.7.x","label":"3.7.x"},{"value":"3.6.0","label":"3.6.0"}]
msk_kafka_version = "3.9.x"
# @param services.msk.numberOfBrokerNodes | displayName=Number of Broker Nodes | description=Number of broker nodes across availability zones | type=number | min=2 | max=30
msk_number_of_broker_nodes = 2
# @param services.msk.brokerNodeInstanceType | displayName=Broker Instance Type | description=EC2 instance type for each broker | type=dropdown | options=[{"value":"kafka.t3.small","label":"kafka.t3.small - 2 vCPU, 2GB (Dev/Test)"},{"value":"kafka.m5.large","label":"kafka.m5.large - 2 vCPU, 8GB"},{"value":"kafka.m5.xlarge","label":"kafka.m5.xlarge - 4 vCPU, 16GB"},{"value":"kafka.m5.2xlarge","label":"kafka.m5.2xlarge - 8 vCPU, 32GB (Production)"}]
msk_broker_node_instance_type = "kafka.t3.small"

# -------------------------------------------------------------------
# DATABASE
# -------------------------------------------------------------------

# @module services.rds | displayName=Relational Database Service (RDS) | category=Database | description=Fully managed relational databases with automated backups
# @param services.rds.engine | displayName=Database Engine | description=Choose your database engine | type=dropdown | options=[{"value":"postgres","label":"PostgreSQL - Open-source, feature-rich"},{"value":"mysql","label":"MySQL - Popular open-source"},{"value":"mariadb","label":"MariaDB - MySQL fork"},{"value":"oracle-ee","label":"Oracle Enterprise"},{"value":"sqlserver-ex","label":"SQL Server Express"}]
rds_engine = "postgres"
# @param services.rds.version | displayName=Engine Version | description=Database version | type=text
rds_version = "15"
# @param services.rds.majorEngineVersion | displayName=Major Engine Version | description=Major version for parameter group | type=text
rds_major_engine_version = "15"
# @param services.rds.family | displayName=Parameter Group Family | description=DB parameter group family | type=text
rds_family = "postgres15"
# @param services.rds.instanceClass | displayName=Instance Class | description=Database compute capacity | type=dropdown | options=[{"value":"db.t3.micro","label":"t3.micro - 1 vCPU, 1GB (Dev)"},{"value":"db.t3.small","label":"t3.small - 2 vCPU, 2GB"},{"value":"db.t3.medium","label":"t3.medium - 2 vCPU, 4GB"},{"value":"db.t3.large","label":"t3.large - 2 vCPU, 8GB"},{"value":"db.r5.large","label":"r5.large - 2 vCPU, 16GB (Memory-optimized)"},{"value":"db.r5.xlarge","label":"r5.xlarge - 4 vCPU, 32GB"}]
rds_instance_class = "db.t3.small"
# @param services.rds.allocatedStorage | displayName=Storage (GB) | description=Initial storage allocation | type=number | min=20 | max=1000
rds_allocated_storage = 20
# @param services.rds.maxAllocatedStorage | displayName=Max Storage (GB) | description=Maximum storage for auto-scaling | type=number | min=20 | max=10000
rds_max_allocated_storage = 100
# @param services.rds.multiAz | displayName=Multi-AZ Deployment | description=Deploy standby in another AZ | type=toggle
rds_multi_az = false
# @param services.rds.backupRetention | displayName=Backup Retention (days) | description=Automated backup retention | type=number | min=0 | max=35
rds_backup_retention_period = 7
# @param services.rds.backupWindow | displayName=Backup Window | description=Daily backup time window (UTC) | type=text
rds_backup_window = "03:00-06:00"
# @param services.rds.maintenanceWindow | displayName=Maintenance Window | description=Weekly maintenance window (UTC) | type=text
rds_maintenance_window = "Mon:00:00-Mon:03:00"
# @param services.rds.deletionProtection | displayName=Deletion Protection | description=Prevent accidental deletion | type=toggle
rds_deletion_protection = true
# @param services.rds.skipFinalSnapshot | displayName=Skip Final Snapshot | description=Skip snapshot on deletion | type=toggle
rds_skip_final_snapshot = false
# @param services.rds.applyImmediately | displayName=Apply Changes Immediately | description=Apply changes without waiting for maintenance | type=toggle
rds_apply_immediately = false
# @param services.rds.autoMinorVersionUpgrade | displayName=Auto Minor Version Upgrade | description=Auto-apply minor patches | type=toggle
rds_auto_minor_version_upgrade = true
# @param services.rds.publiclyAccessible | displayName=Publicly Accessible | description=Assign public IP address | type=toggle
rds_publicly_accessible = false
# @param services.rds.iamDatabaseAuthenticationEnabled | displayName=IAM Authentication | description=Enable IAM-based authentication | type=toggle
rds_iam_database_authentication_enabled = true
# @param services.rds.manageMasterUserPassword | displayName=AWS Managed Password | description=Store password in Secrets Manager | type=toggle
rds_manage_master_user_password = true
# @param services.rds.performanceInsights | displayName=Performance Insights | description=Database performance monitoring | type=toggle
rds_performance_insights_enabled = false
# @param services.rds.performanceInsightsRetentionPeriod | displayName=Insights Retention (days) | description=Performance data retention | type=number | min=7 | max=731
rds_performance_insights_retention_period = 7
# @param services.rds.monitoringInterval | displayName=Enhanced Monitoring (seconds) | description=OS metrics collection frequency | type=dropdown | options=[{"value":0,"label":"Disabled"},{"value":1,"label":"1 second (Most detailed)"},{"value":5,"label":"5 seconds"},{"value":10,"label":"10 seconds"},{"value":15,"label":"15 seconds"},{"value":30,"label":"30 seconds"},{"value":60,"label":"60 seconds (Recommended)"}]
rds_monitoring_interval = 60
# @param services.rds.deleteAutomatedBackups | displayName=Delete Automated Backups | description=Delete backups when instance is deleted | type=toggle
rds_delete_automated_backups = true

# @module services.aurora | displayName=Aurora Serverless | category=Database | description=Serverless relational database with auto-scaling
# @param services.aurora.engine | displayName=Database Engine | description=Aurora database engine | type=dropdown | options=[{"value":"aurora-postgresql","label":"Aurora PostgreSQL"},{"value":"aurora-mysql","label":"Aurora MySQL"}]
aurora_engine = "aurora-postgresql"
# @param services.aurora.engineVersion | displayName=Engine Version | description=Aurora engine version | type=text
aurora_engine_version = "15.10"
# @param services.aurora.instances | displayName=Aurora Instances | description=Map of Aurora instances configuration | type=object | valueType=object | default={"one": {}}
aurora_instances = { one = {} }
# @param services.aurora.serverlessv2MinCapacity | displayName=Min Capacity (ACU) | description=Minimum Aurora Capacity Units | type=number | min=0 | max=128
aurora_serverlessv2_min_capacity = 0
# @param services.aurora.serverlessv2MaxCapacity | displayName=Max Capacity (ACU) | description=Maximum Aurora Capacity Units | type=number | min=0.5 | max=128
aurora_serverlessv2_max_capacity = 10
# @param services.aurora.serverlessv2SecondsUntilAutoPause | displayName=Seconds Until Auto Pause | description=Seconds until Aurora Serverless auto-pauses | type=number | min=300 | max=86400
aurora_serverlessv2_seconds_until_auto_pause = 3600
# @param services.aurora.backupRetention | displayName=Backup Retention (days) | description=Backup retention period in days | type=number | min=1 | max=35
aurora_backup_retention_period = 7
# @param services.aurora.deletionProtection | displayName=Deletion Protection | description=Enable deletion protection | type=toggle
aurora_deletion_protection = true
# @param services.aurora.enableHttpEndpoint | displayName=Data API | description=Enable HTTP endpoint for Data API | type=toggle
aurora_enable_http_endpoint = true
# @param services.aurora.iamDatabaseAuthenticationEnabled | displayName=IAM Database Authentication | description=Enable IAM database authentication | type=toggle
aurora_iam_database_authentication_enabled = true
# @param services.aurora.monitoringInterval | displayName=Enhanced Monitoring Interval (seconds) | description=Enhanced monitoring interval | type=dropdown | options=[{"value":0,"label":"Disabled"},{"value":1,"label":"1 second"},{"value":5,"label":"5 seconds"},{"value":10,"label":"10 seconds"},{"value":15,"label":"15 seconds"},{"value":30,"label":"30 seconds"},{"value":60,"label":"60 seconds"}]
aurora_monitoring_interval = 60
# @param services.aurora.applyImmediately | displayName=Apply Immediately | description=Apply changes immediately | type=toggle
aurora_apply_immediately = true
# @param services.aurora.skipFinalSnapshot | displayName=Skip Final Snapshot | description=Skip final snapshot when deleting | type=toggle
aurora_skip_final_snapshot = false
# @param services.aurora.manageMasterUserPassword | displayName=AWS Managed Password | description=Store password in Secrets Manager | type=toggle
aurora_manage_master_user_password = true
# @param services.aurora.deleteAutomatedBackups | displayName=Delete Automated Backups | description=Delete automated backups on cluster deletion | type=toggle
aurora_delete_automated_backups = true

# -------------------------------------------------------------------
# OpenSearch
# -------------------------------------------------------------------

# @module services.opensearch | displayName=OpenSearch Service | category=Database | description=Managed search and analytics service
# @param services.opensearch.domainName | displayName=Domain Name | description=OpenSearch domain name | type=text
opensearch_domain_name = "opensearch"
# @param services.opensearch.version | displayName=OpenSearch Version | description=OpenSearch version | type=dropdown | options=[{"value":"OpenSearch_2.19","label":"OpenSearch 2.19"},{"value":"OpenSearch_2.11","label":"OpenSearch 2.11"},{"value":"OpenSearch_2.9","label":"OpenSearch 2.9"},{"value":"OpenSearch_1.3","label":"OpenSearch 1.3"}]
opensearch_version = "OpenSearch_2.19"
# @param services.opensearch.instanceCount | displayName=Instance Count | description=Number of data instances | type=number | min=1 | max=20
opensearch_instance_count = 2
# @param services.opensearch.instanceType | displayName=Instance Type | description=OpenSearch instance type | type=dropdown | options=[{"value":"t3.small.search","label":"t3.small.search"},{"value":"t3.medium.search","label":"t3.medium.search"},{"value":"m5.large.search","label":"m5.large.search"},{"value":"m7g.medium.search","label":"m7g.medium.search"},{"value":"m7g.large.search","label":"m7g.large.search"}]
opensearch_instance_type = "m7g.medium.search"
# @param services.opensearch.ebsEnabled | displayName=EBS Storage | description=Enable EBS storage volumes | type=toggle
opensearch_ebs_enabled = true
# @param services.opensearch.ebsVolumeType | displayName=EBS Volume Type | description=EBS volume type | type=dropdown | options=[{"value":"gp3","label":"gp3"},{"value":"gp2","label":"gp2"},{"value":"io1","label":"io1"}]
opensearch_ebs_volume_type = "gp3"
# @param services.opensearch.ebsVolumeSize | displayName=EBS Volume Size (GB) | description=EBS volume size per instance | type=number | min=10 | max=1000
opensearch_ebs_volume_size = 64
# @param services.opensearch.customEndpointEnabled | displayName=Custom Endpoint | description=Enable custom endpoint | type=toggle
opensearch_custom_endpoint_enabled = false
# @param services.opensearch.masterUserName | displayName=Master User Name | description=Master user name for authentication | type=text
opensearch_master_user_name = "admin"
# @param services.opensearch.dedicatedMasterEnabled | displayName=Dedicated Master | description=Enable dedicated master nodes | type=toggle
opensearch_dedicated_master_enabled = false
# @param services.opensearch.dedicatedMasterType | displayName=Master Instance Type | description=Master node instance type | type=dropdown | options=[{"value":"t3.small.search","label":"t3.small.search"},{"value":"t3.medium.search","label":"t3.medium.search"},{"value":"m5.large.search","label":"m5.large.search"}]
opensearch_dedicated_master_type = "t3.small.search"
# @param services.opensearch.dedicatedMasterCount | displayName=Master Node Count | description=Number of master nodes | type=number | min=0 | max=5
opensearch_dedicated_master_count = 0
# @param services.opensearch.nodeToNodeEncryption | displayName=Node-to-Node Encryption | description=Enable node-to-node encryption | type=toggle
opensearch_node_to_node_encryption = true
# @param services.opensearch.enforceHttps | displayName=Enforce HTTPS | description=Enforce HTTPS for all traffic | type=toggle
opensearch_enforce_https = true
# @param services.opensearch.tlsSecurityPolicy | displayName=TLS Security Policy | description=TLS security policy | type=dropdown | options=[{"value":"Policy-Min-TLS-1-0-2019-07","label":"TLS 1.0 (Minimum)"},{"value":"Policy-Min-TLS-1-2-2019-07","label":"TLS 1.2 (Minimum)"},{"value":"Policy-Min-TLS-1-2-PFS-2023-10","label":"TLS 1.2 PFS"}]
opensearch_tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
# @param services.opensearch.advancedSecurityEnabled | displayName=Advanced Security | description=Enable advanced security options | type=toggle
opensearch_advanced_security_enabled = true
# @param services.opensearch.internalUserDatabaseEnabled | displayName=Internal User Database | description=Enable internal user database | type=toggle
opensearch_internal_user_database_enabled = true
# @param services.opensearch.createAccessPolicy | displayName=Create Access Policy | description=Create domain access policy | type=toggle
opensearch_create_access_policy = true
# @param services.opensearch.ipAddressType | displayName=IP Address Type | description=IP address type for the domain | type=dropdown | options=[{"value":"ipv4","label":"IPv4 only"},{"value":"dualstack","label":"IPv4 and IPv6 (Dual Stack)"}]
opensearch_ip_address_type = "dualstack"
# @param services.opensearch.allowExplicitIndex | valueType=string | default=true | displayName=Allow Explicit Index | description=Allow explicit index in multi-action requests | type=toggle
opensearch_allow_explicit_index = "true"

# -------------------------------------------------------------------
# ELASTICACHE
# -------------------------------------------------------------------

# @module services.elasticache | displayName=ElastiCache | category=Database | description=Managed in-memory caching - Redis, Valkey, or Memcached
# @param services.elasticache.engine | displayName=Cache Engine | description=Choose your caching engine | type=dropdown | options=[{"value":"valkey","label":"Valkey - Open-source Redis alternative (recommended)"},{"value":"redis","label":"Redis - In-memory data store"},{"value":"memcached","label":"Memcached - Simple key-value cache"}]
elasticache_engine = "valkey"
# @param services.elasticache.engineVersion | displayName=Engine Version | description=Cache engine version | type=text
elasticache_engine_version = "7.2"
# @param services.elasticache.nodeType | displayName=Node Type | description=Instance type for cache nodes | type=dropdown | options=[{"value":"cache.t4g.micro","label":"t4g.micro - 0.5GB (Graviton, cost-effective)"},{"value":"cache.t4g.small","label":"t4g.small - 1.37GB (Graviton, recommended)"},{"value":"cache.t4g.medium","label":"t4g.medium - 3.09GB (Graviton)"},{"value":"cache.t3.micro","label":"t3.micro - 0.5GB (x86)"},{"value":"cache.t3.small","label":"t3.small - 1.37GB (x86)"},{"value":"cache.t3.medium","label":"t3.medium - 3.09GB (x86)"},{"value":"cache.r6g.large","label":"r6g.large - 13.07GB (Memory-optimized Graviton)"},{"value":"cache.r7g.large","label":"r7g.large - 13.07GB (Latest Graviton)"}]
elasticache_node_type = "cache.t4g.small"
# @param services.elasticache.numCacheNodes | displayName=Number of Cache Nodes | description=Number of cache nodes in the cluster | type=number | min=1 | max=20
elasticache_num_cache_nodes = 1
# @param services.elasticache.parameterGroupFamily | displayName=Parameter Group Family | description=Must match your engine and version | type=dropdown | options=[{"value":"valkey7","label":"valkey7"},{"value":"redis7","label":"redis7"},{"value":"redis6.x","label":"redis6.x"},{"value":"memcached1.6","label":"memcached1.6"}]
elasticache_parameter_group_family = "valkey7"
# @param services.elasticache.transitEncryption | displayName=Transit Encryption (TLS) | description=Encrypt data in transit | type=toggle
elasticache_transit_encryption_enabled = true
# @param services.elasticache.atRestEncryption | displayName=At-Rest Encryption | description=Encrypt data at rest | type=toggle
elasticache_at_rest_encryption_enabled = true
# @param services.elasticache.authTokenEnabled | displayName=Auth Token (Password) | description=Enable authentication token (Redis/Valkey AUTH) | type=toggle
elasticache_auth_token_enabled = true
# @param services.elasticache.maintenanceWindow | displayName=Maintenance Window | description=Preferred maintenance window (UTC) | type=text
elasticache_maintenance_window = "sun:05:00-sun:06:00"
# @param services.elasticache.snapshotRetentionLimit | displayName=Snapshot Retention Days | description=Number of days to retain automatic snapshots | type=number | min=0 | max=35
elasticache_snapshot_retention_limit = 7
# @param services.elasticache.snapshotWindow | displayName=Snapshot Window | description=Daily time range for automatic snapshots (UTC) | type=text
elasticache_snapshot_window = "03:00-05:00"
# @param services.elasticache.automaticFailover | displayName=Automatic Failover | description=Enable automatic failover to replica | type=toggle
elasticache_automatic_failover_enabled = false
# @param services.elasticache.multiAz | displayName=Multi-AZ Deployment | description=Deploy across multiple availability zones | type=toggle
elasticache_multi_az_enabled = false

# -------------------------------------------------------------------
# ECR
# -------------------------------------------------------------------

# @module services.ecr | displayName=Elastic Container Registry (ECR) | category=Storage | description=Managed Docker container registry with vulnerability scanning
# @param services.ecr.repositoryNames | valueType=list | displayName=Repository Names | description=List of ECR repository names to create | type=array
ecr_repository_names = []
# @param services.ecr.repositoryType | displayName=Repository Type | description=Repository visibility (applies to all repositories) | type=dropdown | options=[{"value":"private","label":"Private - Requires authentication"},{"value":"public","label":"Public - Accessible without authentication"}]
ecr_repository_type = "private"
# @param services.ecr.imageTagMutability | displayName=Image Tag Mutability | description=Prevent tag overwrites | type=dropdown | options=[{"value":"MUTABLE","label":"Mutable - Tags can be overwritten"},{"value":"IMMUTABLE","label":"Immutable - Tags cannot be overwritten"}]
ecr_image_tag_mutability = "IMMUTABLE"
# @param services.ecr.encryptionType | displayName=Encryption Type | description=Image encryption method | type=dropdown | options=[{"value":"AES256","label":"AES256 - AWS managed encryption"},{"value":"KMS","label":"KMS - Customer managed keys (additional cost)"}]
ecr_encryption_type = "AES256"
# @param services.ecr.enableScanning | displayName=Enable Vulnerability Scanning | description=Automatically scan images for vulnerabilities on push | type=toggle
ecr_enable_scanning = true
# @param services.ecr.scanType | displayName=Scan Type | description=Level of vulnerability scanning | type=dropdown | options=[{"value":"BASIC","label":"Basic - Standard CVE scanning (free)"},{"value":"ENHANCED","label":"Enhanced - AWS Inspector integration (charged)"}]
ecr_scan_type = "BASIC"
# @param services.ecr.createLifecyclePolicy | displayName=Enable Lifecycle Policy | description=Automatically cleanup old images to save storage costs | type=toggle
ecr_create_lifecycle_policy = true
# @param services.ecr.lifecyclePolicyMaxImages | displayName=Maximum Images to Keep | description=Number of images to retain per repository | type=number | min=1 | max=1000
ecr_lifecycle_policy_max_images = 25
# @param services.ecr.enableReplication | displayName=Enable Cross-Region Replication | description=Replicate images to other regions for disaster recovery | type=toggle
ecr_enable_replication = false
# @param services.ecr.replicationDestinations | valueType=list | displayName=Replication Destination Regions | description=List of AWS regions to replicate images to | type=array
ecr_replication_destinations = []

# -------------------------------------------------------------------
# WAF
# -------------------------------------------------------------------

# @module services.waf | displayName=Web Application Firewall (WAF) | category=Security | description=Protect web apps from common exploits and attacks
# @param services.waf.name | displayName=WAF Name | description=Name for the WAF Web ACL | type=text
waf_name = "waf"
# @param services.waf.description | displayName=Description | description=Description of the WAF configuration | type=text
waf_description = "Default AWS WAF Managed rule set"
# @param services.waf.scope | displayName=Scope | description=Where the WAF will be applied | type=dropdown | options=[{"value":"REGIONAL","label":"Regional - ALB, API Gateway, AppSync"},{"value":"CLOUDFRONT","label":"CloudFront - Global edge locations"}]
waf_scope = "REGIONAL"
# @param services.waf.cloudwatchMetricsEnabled | displayName=CloudWatch Metrics | description=Enable detailed metrics | type=toggle
waf_cloudwatch_metrics_enabled = true
# @param services.waf.metricName | displayName=Metric Name | description=Name for CloudWatch metrics | type=text
waf_metric_name = "WAF-metrics"
# @param services.waf.sampledRequestsEnabled | displayName=Sampled Requests | description=Store samples of blocked/allowed requests | type=toggle
waf_sampled_requests_enabled = true

# -------------------------------------------------------------------
# S3
# -------------------------------------------------------------------

# @module services.s3 | displayName=Simple Storage Service (S3) | category=Storage | description=Scalable object storage with 99.999999999% durability
# @param services.s3.bucketNames | valueType=list | displayName=Bucket Names | description=List of bucket names to create (one per line) | type=array
s3_bucket_names = []

# -------------------------------------------------------------------
# LAMBDA
# -------------------------------------------------------------------

# Hidden from the wizard: lambda.tf generates fine but expects deployment
# packages (lambda-packages/*.zip) the wizard cannot supply, so a plain
# apply fails. Drop available=false once package upload is supported.
# OpenPrime-151
# @module services.lambda | displayName=AWS Lambda | category=Compute | description=Serverless compute - run code without managing servers | available=false
# @param services.lambda.functionNames | valueType=list | displayName=Function Names | description=List of Lambda function names to create (one per line) | type=array
lambda_function_names = []

# -------------------------------------------------------------------
# SQS
# -------------------------------------------------------------------

# @module services.sqs | displayName=Simple Queue Service (SQS) | category=Integration | description=Managed message queuing for decoupled microservices
# @param services.sqs.queueNames | valueType=list | displayName=Queue Names | description=Queue names to create | type=array
sqs_queue_names = []
# @param services.sqs.fifoQueues | displayName=FIFO Queues | description=Enable First-In-First-Out ordering | type=toggle
sqs_fifo_queues = false
# @param services.sqs.contentBasedDeduplication | displayName=Content-Based Deduplication | description=Auto-deduplicate based on message content | type=toggle
sqs_content_based_deduplication = false
# @param services.sqs.visibilityTimeout | displayName=Visibility Timeout (seconds) | description=How long messages are invisible after being received | type=number | min=0 | max=43200
sqs_visibility_timeout = 30
# @param services.sqs.messageRetention | displayName=Message Retention (seconds) | description=How long to keep messages before deletion | type=number | min=60 | max=1209600
sqs_message_retention = 345600
# @param services.sqs.maxMessageSize | displayName=Max Message Size (bytes) | description=Maximum size per message | type=number | min=1024 | max=262144
sqs_max_message_size = 262144
# @param services.sqs.delaySeconds | displayName=Delivery Delay (seconds) | description=Delay before messages become available | type=number | min=0 | max=900
sqs_delay_seconds = 0
# @param services.sqs.receiveWaitTime | displayName=Receive Wait Time (seconds) | description=Long polling wait time | type=number | min=0 | max=20
sqs_receive_wait_time = 0
# @param services.sqs.createDeadLetterQueue | displayName=Dead Letter Queue | description=Capture failed messages for debugging | type=toggle
sqs_create_dlq = false
# @param services.sqs.maxReceiveCount | displayName=Max Receive Count | description=Attempts before moving to DLQ | type=number | min=1 | max=1000
sqs_max_receive_count = 3
# @param services.sqs.enableEncryption | displayName=Server-Side Encryption | description=Encrypt messages at rest | type=toggle
sqs_enable_encryption = true

# -------------------------------------------------------------------
# SNS
# -------------------------------------------------------------------

# @module services.sns | displayName=Simple Notification Service (SNS) | category=Integration | description=Pub/sub messaging for fan-out notifications to subscribers
# @param services.sns.topicNames | valueType=list | displayName=Topic Names | description=SNS topics to create | type=array
sns_topic_names = []
# @param services.sns.fifoTopics | displayName=FIFO Topics | description=Enable First-In-First-Out ordering | type=toggle
sns_fifo_topics = false
# @param services.sns.contentBasedDeduplication | displayName=Content-Based Deduplication | description=Auto-deduplicate based on message content | type=toggle
sns_content_based_deduplication = false
# @param services.sns.enableEncryption | displayName=Enable Encryption | description=Encrypt messages at rest | type=toggle
sns_enable_encryption = false
# @param services.sns.kmsKeyId | valueType=string | default= | displayName=KMS Key ID | description=KMS key for encryption | type=text
sns_kms_key_id = null

# -------------------------------------------------------------------
# CLOUDFRONT
# -------------------------------------------------------------------

# @module services.cloudfront | displayName=CloudFront | category=Networking | description=Global CDN for fast content delivery with edge caching
# @param services.cloudfront.distributionNames | valueType=list | displayName=Distribution Aliases | description=Custom domain names for distributions | type=array
cloudfront_distribution_names = []
# @param services.cloudfront.priceClass | displayName=Price Class | description=Edge location coverage (affects cost) | type=dropdown | options=[{"value":"PriceClass_100","label":"US, Canada, Europe (Lowest cost)"},{"value":"PriceClass_200","label":"+ Asia, Middle East, Africa"},{"value":"PriceClass_All","label":"All Edge Locations (Global)"}]
cloudfront_price_class = "PriceClass_100"
# @param services.cloudfront.enableIpv6 | displayName=Enable IPv6 | description=Support IPv6 client connections | type=toggle
cloudfront_enable_ipv6 = true
# @param services.cloudfront.enableWaf | displayName=WAF Integration | description=Attach AWS WAF for protection | type=toggle
cloudfront_enable_waf = false
# @param services.cloudfront.enableLogging | displayName=Access Logging | description=Log requests to S3 | type=toggle
cloudfront_enable_logging = false
# @param services.cloudfront.loggingBucket | valueType=string | default= | displayName=Logging Bucket | description=S3 bucket for access logs | type=text
cloudfront_logging_bucket = null

# -------------------------------------------------------------------
# ROUTE53
# -------------------------------------------------------------------

# @module services.route53 | displayName=Route 53 | category=Networking | description=Scalable DNS and domain management with health checks
# @param services.route53.zoneNames | valueType=list | displayName=Hosted Zone Domains | description=Domain names to manage | type=array
route53_zone_names = []
# @param services.route53.privateZones | displayName=Private Hosted Zones | description=Internal DNS for VPC resources | type=toggle
route53_private_zones = false
# @param services.route53.forceDestroy | displayName=Force Destroy | description=Allow zone deletion with records | type=toggle
route53_force_destroy = false
# @param services.route53.enableDnssec | displayName=Enable DNSSEC | description=Enable DNS Security Extensions | type=toggle
route53_enable_dnssec = false

# -------------------------------------------------------------------
# HELM CHARTS
# -------------------------------------------------------------------

# @param services.eks.helmCharts | exclude=true
helm_charts = {}
