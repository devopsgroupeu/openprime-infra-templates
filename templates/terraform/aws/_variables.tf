# -------------------------------------------------------------------
# GLOBAL
# -------------------------------------------------------------------

variable "region" {
  type        = string
  description = "The AWS region, where networking infrastructure will be created (e.g. 'eu-west-1')"
  default     = "eu-west-1"
}

variable "global_prefix" {
  type        = string
  description = "Global prefix to be used in almost every resource name created by this code"
  default     = ""
}

variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "development"
}

variable "environment_short" {
  description = "Short name of the environment (e.g., dev)"
  type        = string
  default     = "dev"
}

variable "global_tags" {
  type        = map(string)
  description = "Global tags to be used in almost every resource created by this code"
  default     = {}
}

# -------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to select"
  type        = number
  default     = 2
}

variable "create_public_subnets" {
  description = "Wether to create public subnets"
  type        = bool
  default     = true
}

variable "create_private_subnets" {
  description = "Wether to create private subnets"
  type        = bool
  default     = true
}

variable "create_intra_subnets" {
  description = "Wether to create intra subnets"
  type        = bool
  default     = false
}

variable "create_database_subnets" {
  description = "Wether to create database subnets"
  type        = bool
  default     = false
}

variable "nat_gateway_strategy" {
  description = "Strategy for creating NAT gateways. Available options are `NO_NAT`, `SINGLE`, `ONE_PER_SUBNET` or `ONE_PER_AZ`. Default is `ONE_PER_SUBNET`"
  type        = string
  default     = "SINGLE"

  validation {
    condition = can(index([
      "NO_NAT",
      "SINGLE",
      "ONE_PER_SUBNET",
      "ONE_PER_AZ"
    ], var.nat_gateway_strategy) >= 0)

    error_message = "Value of 'nat_gateway_strategy' must be on of `NO_NAT`, `SINGLE`, `ONE_PER_SUBNET` or `ONE_PER_AZ` option"
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "create_database_subnet_group" {
  description = "Whether to create database subnet group"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway for the VPC"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for EKS cluster"
  default     = "1.33"
}

variable "enable_cluster_creator_admin_permissions" {
  type        = bool
  description = "Enable cluster creator admin permissions"
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public access to cluster endpoint"
  default     = true
}

variable "authentication_mode" {
  type        = string
  description = "Authentication mode for EKS cluster"
  default     = "API"
}

variable "enable_irsa" {
  type        = bool
  description = "Enable IAM roles for service accounts"
  default     = true
}

variable "default_node_group_ami_type" {
  type        = string
  description = "AMI type of default node group"
  default     = "BOTTLEROCKET_x86_64"
}

variable "default_node_group_instance_types" {
  type        = list(string)
  description = "Instance type of default node group"
  default     = ["t3.medium"]
}

variable "default_node_group_capacity_type" {
  type        = string
  description = "Capacity type of default node group"
  default     = "ON_DEMAND"
}

variable "default_node_group_min_size" {
  type        = number
  description = "Minimum count of nodes in default node group"
  default     = 1
}

variable "default_node_group_max_size" {
  type        = number
  description = "Maximum count of nodes in default node group"
  default     = 10
}

variable "default_node_group_desired_size" {
  type        = number
  description = "Desired count of nodes in default node group"
  default     = 2
}

variable "default_node_group_max_unavailable" {
  type        = number
  description = "Count of nodes which can be unavailable when performing a rolling update"
  default     = 1
}

variable "karpenter_nodepool_arch" {
  type        = string
  description = "Architecture of default karpenter nodepool nodes"
  default     = "amd64"
}

variable "karpenter_nodepool_capacity_type" {
  type        = string
  description = "Capacity type of default karpenter nodepool nodes"
  default     = "spot"
}

variable "aws_lb_replica_count" {
  type        = number
  description = "Count of replicas of aws-lb-controller"
  default     = 2
}

variable "aws_lb_pdb_max_unavailable" {
  type        = number
  description = "Count of max unavailable replicas for aws-lb-controller"
  default     = 1
}

variable "eks_addon_coredns_most_recent" {
  type        = bool
  description = "Whether to use most recent version of CoreDNS addon"
  default     = true
}

variable "eks_addon_pod_identity_most_recent" {
  type        = bool
  description = "Whether to use most recent version of Pod Identity addon"
  default     = true
}

variable "eks_addon_pod_identity_before_compute" {
  type        = bool
  description = "Whether to install Pod Identity addon before compute"
  default     = true
}

variable "eks_addon_kube_proxy_most_recent" {
  type        = bool
  description = "Whether to use most recent version of kube-proxy addon"
  default     = true
}

variable "eks_addon_vpc_cni_most_recent" {
  type        = bool
  description = "Whether to use most recent version of VPC CNI addon"
  default     = true
}

variable "eks_addon_vpc_cni_before_compute" {
  type        = bool
  description = "Whether to install VPC CNI addon before compute"
  default     = true
}

variable "eks_addon_ebs_csi_most_recent" {
  type        = bool
  description = "Whether to use most recent version of EBS CSI driver"
  default     = true
}

variable "eks_addon_efs_csi_most_recent" {
  type        = bool
  description = "Whether to use most recent version of EFS CSI driver"
  default     = true
}

variable "default_node_group_use_latest_ami" {
  type        = bool
  description = "Whether to use latest AMI release version for default node group"
  default     = true
}

variable "default_node_group_iam_additional_policies" {
  type        = map(string)
  description = "Additional IAM policies to attach to default node group"
  default = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
}

# -------------------------------------------------------------------
# ECR
# -------------------------------------------------------------------

variable "ecr_repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
  default     = []
}

variable "ecr_image_tag_mutability" {
  description = "Set the mutability of image tags. Valid values are 'MUTABLE' and 'IMMUTABLE'"
  type        = string
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "Must be either 'MUTABLE' or 'IMMUTABLE'"
  }
  default = "IMMUTABLE"
}

variable "ecr_enable_scanning" {
  description = "Enable image scanning on push for ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_scan_type" {
  description = "The type of scanning to perform on images. Valid values are 'BASIC' and 'ENHANCED'"
  type        = string
  validation {
    condition     = contains(["BASIC", "ENHANCED"], var.ecr_scan_type)
    error_message = "Must be either 'BASIC' or 'ENHANCED'"
  }
  default = "BASIC"
}

variable "ecr_enable_replication" {
  description = "Enable ECR replication configuration"
  type        = bool
  default     = false
}

variable "ecr_repository_type" {
  description = "Set repository type. Valid values are 'private' or 'public'"
  type        = string
  validation {
    condition     = contains(["private", "public"], var.ecr_repository_type)
    error_message = "Must be either 'private' or 'public'"
  }
  default = "private"
}

variable "ecr_replication_destinations" {
  description = "List of destination regions for ECR replication"
  type        = list(string)
  default     = []
}

variable "ecr_create_lifecycle_policy" {
  description = "Enable lifecycle policy for ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_repository_read_write_access_arns" {
  description = "List of ARNs for read/write access to ECR repositories"
  type        = list(string)
  default     = []
}

variable "ecr_repository_encryption_type" {
  description = "Encryption type for ECR repositories. Must be 'KMS' or 'AES256'."
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["KMS", "AES256"], var.ecr_repository_encryption_type)
    error_message = "Must be either 'KMS' or 'AES256'"
  }
}

variable "ecr_lifecycle_policy_rule_priority" {
  description = "Priority for lifecycle policy rule"
  type        = number
  default     = 1
}

variable "ecr_lifecycle_policy_description" {
  description = "Description for lifecycle policy"
  type        = string
  default     = "Keep last 25 images"
}

variable "ecr_lifecycle_policy_tag_status" {
  description = "Tag status for lifecycle policy"
  type        = string
  default     = "tagged"
}

variable "ecr_lifecycle_policy_tag_prefix_list" {
  description = "Tag prefix list for lifecycle policy"
  type        = list(string)
  default     = ["v"]
}

variable "ecr_lifecycle_policy_count_type" {
  description = "Count type for lifecycle policy"
  type        = string
  default     = "imageCountMoreThan"
}

variable "ecr_lifecycle_policy_count_number" {
  description = "Count number for lifecycle policy"
  type        = number
  default     = 25
}

variable "ecr_lifecycle_policy_action_type" {
  description = "Action type for lifecycle policy"
  type        = string
  default     = "expire"
}

# -------------------------------------------------------------------
# RDS
# -------------------------------------------------------------------

variable "rds_engine" {
  type        = string
  description = "The database engine to use for the RDS instance (e.g., mysql, postgres)"
}

variable "rds_engine_version" {
  type        = string
  description = "The version of the database engine to use for the RDS instance. (e.g. for MySQL - 8.0.40; for PostgreSQL - 15)"
}

variable "rds_major_engine_version" {
  type        = string
  description = "The major version of the database engine (e.g. for MySQL - 8.0; for PostgreSQL - 15)"
}

variable "rds_family" {
  type        = string
  description = "The family of the database engine (e.g. for MySQL - mysql8.0; for PostgreSQL - postgres15)"
}

variable "rds_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "The instance class for the RDS instance (e.g., db.t3.micro)"
}

variable "rds_apply_immediately" {
  type        = bool
  description = "Apply changes immediately"
  default     = false
}

variable "rds_deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "rds_skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on deletion"
  default     = true
}

variable "rds_delete_automated_backups" {
  type        = bool
  description = "Whether to delete automated backups"
  default     = true
}

variable "rds_backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 7
}

variable "rds_multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = true
}

variable "rds_auto_minor_version_upgrade" {
  type        = bool
  description = "Enable automatic minor version upgrades"
  default     = true
}

variable "rds_manage_master_user_password" {
  type        = bool
  description = "Whether RDS manages the master user password"
  default     = false
}

variable "rds_allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "Maximum allocated storage for autoscaling"
  default     = 50
}

variable "rds_iam_database_authentication_enabled" {
  type        = bool
  description = "Enable IAM database authentication"
  default     = true
}

variable "rds_publicly_accessible" {
  type        = bool
  description = "Whether the RDS instance is publicly accessible"
  default     = false
}

variable "rds_performance_insights_enabled" {
  type        = bool
  description = "Enable Performance Insights"
  default     = false
}

variable "rds_performance_insights_retention_period" {
  type        = number
  description = "Performance Insights retention period in days"
  default     = 7
}

variable "rds_monitoring_interval" {
  type        = number
  description = "Monitoring interval in seconds"
  default     = 60
}

variable "rds_maintenance_window" {
  type        = string
  description = "Maintenance window"
  default     = "Mon:00:00-Mon:03:00"
}

variable "rds_backup_window" {
  type        = string
  description = "Backup window"
  default     = "03:00-06:00"
}

# -------------------------------------------------------------------
# AURORA
# -------------------------------------------------------------------

variable "aurora_engine" {
  type        = string
  description = "The Aurora database engine to use (e.g. for MySQL - aurora-mysql; for PostgreSQL - aurora-postgresql)"
}

variable "aurora_engine_version" {
  type        = string
  description = "The version of the Aurora MySQL engine to use. (e.g. for MySQL - 8.0.mysql_aurora.3.08.0; for PostgreSQL - 15.8)"
}

variable "aurora_instances" {
  type        = map(any)
  description = "Map of Aurora instances"
  default = {
    one = {}
  }
}

variable "aurora_serverlessv2_min_capacity" {
  type        = number
  description = "Minimum capacity for Aurora Serverless v2"
  default     = 0
}

variable "aurora_serverlessv2_max_capacity" {
  type        = number
  description = "Maximum capacity for Aurora Serverless v2"
  default     = 10
}

variable "aurora_serverlessv2_seconds_until_auto_pause" {
  type        = number
  description = "Seconds until auto pause for Aurora Serverless v2"
  default     = 3600
}

variable "aurora_enable_http_endpoint" {
  type        = bool
  description = "Enable HTTP endpoint for Aurora"
  default     = true
}

variable "aurora_iam_database_authentication_enabled" {
  type        = bool
  description = "Enable IAM database authentication for Aurora"
  default     = true
}

variable "aurora_monitoring_interval" {
  type        = number
  description = "Monitoring interval in seconds for Aurora"
  default     = 60
}

variable "aurora_apply_immediately" {
  type        = bool
  description = "Apply changes immediately for Aurora"
  default     = true
}

variable "aurora_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for Aurora"
  default     = false
}

variable "aurora_skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on deletion for Aurora"
  default     = true
}

variable "aurora_delete_automated_backups" {
  type        = bool
  description = "Whether to delete automated backups for Aurora"
  default     = true
}

variable "aurora_backup_retention_period" {
  type        = number
  description = "Backup retention period in days for Aurora"
  default     = 7
}

# -------------------------------------------------------------------
# OpenSearch
# -------------------------------------------------------------------

variable "opensearch_acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for your custom endpoint. This variable is required if custom_endpoint_enabled is set to true."
  default     = ""
}

variable "opensearch_custom_endpoint" {
  type        = string
  description = "Fully qualified domain for your custom endpoint. This variable is required if custom_endpoint_enabled is set to true."
  default     = ""
}

variable "opensearch_custom_endpoint_enabled" {
  type        = bool
  description = "Whether to enable custom endpoint for the Opensearch domain."
  default     = false
}

variable "opensearch_domain_name" {
  type        = string
  description = "Name of the Opensearch domain."
  default     = "opensearch"
}

variable "opensearch_ebs_enabled" {
  type        = bool
  description = "Whether EBS volumes are attached to data nodes in the domain."
  default     = true
}

variable "opensearch_ebs_volume_type" {
  type        = string
  description = "Type of EBS volumes attached to data nodes."
  default     = "gp3"
}

variable "opensearch_ebs_volume_size" {
  type        = number
  description = "Size of EBS volumes attached to data nodes (in GiB)."
  default     = 64
}

variable "opensearch_instance_count" {
  type        = number
  description = "Number of instances in the cluster."
  default     = 3
}

variable "opensearch_instance_type" {
  type        = string
  description = "Instance type of data nodes in the cluster."
  default     = "m7g.medium.search"
}

variable "opensearch_master_user_name" {
  type        = string
  description = "Main user's username."
  default     = "admin"
}

variable "opensearch_master_user_password" {
  type        = string
  description = "Main user's passsword."
  default     = ""
}

variable "opensearch_version" {
  type        = string
  description = "Version of OpenSearch."
  default     = "OpenSearch_2.19"
}

variable "opensearch_create_access_policy" {
  type        = bool
  description = "Whether to create an access policy for OpenSearch"
  default     = true
}

variable "opensearch_ip_address_type" {
  type        = string
  description = "IP address type for OpenSearch domain"
  default     = "dualstack"
}

variable "opensearch_allow_explicit_index" {
  type        = string
  description = "Allow explicit index in REST actions"
  default     = "true"
}

variable "opensearch_enforce_https" {
  type        = bool
  description = "Whether to enforce HTTPS"
  default     = true
}

variable "opensearch_tls_security_policy" {
  type        = string
  description = "TLS security policy for OpenSearch domain"
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "opensearch_advanced_security_enabled" {
  type        = bool
  description = "Whether advanced security is enabled"
  default     = true
}

variable "opensearch_internal_user_database_enabled" {
  type        = bool
  description = "Whether internal user database is enabled"
  default     = true
}

variable "opensearch_dedicated_master_enabled" {
  type        = bool
  description = "Whether dedicated master nodes are enabled"
  default     = false
}

variable "opensearch_dedicated_master_type" {
  type        = string
  description = "Instance type for dedicated master nodes"
  default     = "t3.small.search"
}

variable "opensearch_dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes"
  default     = 0
  validation {
    condition     = var.opensearch_dedicated_master_count == 0 || var.opensearch_dedicated_master_count == 3 || var.opensearch_dedicated_master_count == 5
    error_message = "Dedicated master count must be 0, 3, or 5"
  }
}

variable "opensearch_node_to_node_encryption" {
  type        = bool
  description = "Whether to enable node-to-node encryption"
  default     = true
}

# -------------------------------------------------------------------
# MSK
# -------------------------------------------------------------------

variable "msk_kafka_version" {
  type        = string
  description = "Kafka version for MSK cluster"
  default     = "3.5.1"
}

variable "msk_number_of_broker_nodes" {
  type        = number
  description = "Number of broker nodes in MSK cluster"
  default     = 2
}

variable "msk_broker_node_instance_type" {
  type        = string
  description = "Instance type for MSK broker nodes"
  default     = "kafka.t3.small"
}

# -------------------------------------------------------------------
# KARPENTER
# -------------------------------------------------------------------

variable "karpenter_node_iam_role_use_name_prefix" {
  type        = bool
  description = "Whether to use name prefix for Karpenter node IAM role"
  default     = false
}

variable "karpenter_create_pod_identity_association" {
  type        = bool
  description = "Whether to create pod identity association for Karpenter"
  default     = true
}

variable "karpenter_node_iam_role_additional_policies" {
  type        = map(string)
  description = "Additional IAM policies for Karpenter node role"
  default = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

# -------------------------------------------------------------------
# WAF
# -------------------------------------------------------------------

variable "waf_name" {
  type        = string
  description = "Name of the WAF Web ACL"
  default     = "waf"
}

variable "waf_description" {
  type        = string
  description = "Description of the WAF Web ACL"
  default     = "Default AWS WAF Managed rule set"
}

variable "waf_scope" {
  type        = string
  description = "Scope of the WAF Web ACL (REGIONAL or CLOUDFRONT)"
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.waf_scope)
    error_message = "Must be either 'REGIONAL' or 'CLOUDFRONT'"
  }
}

variable "waf_cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether to enable CloudWatch metrics for WAF"
  default     = true
}

variable "waf_metric_name" {
  type        = string
  description = "Metric name for WAF CloudWatch metrics"
  default     = "WAF-metrics"
}

variable "waf_sampled_requests_enabled" {
  type        = bool
  description = "Whether to enable sampled requests for WAF"
  default     = true
}

# -------------------------------------------------------------------
# S3
# -------------------------------------------------------------------

# @param services.s3.bucketNames
variable "s3_bucket_names" {
  description = "List of S3 bucket names to create"
  type        = list(string)
  default     = []
}

# @param services.s3.versioningEnabled
variable "s3_versioning_enabled" {
  description = "Enable versioning for S3 buckets"
  type        = bool
  default     = false
}

# @param services.s3.encryptionType
variable "s3_encryption_type" {
  description = "Encryption type for S3 buckets (AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

# @param services.s3.blockPublicAccess
variable "s3_block_public_access" {
  description = "Block all public access to S3 buckets"
  type        = bool
  default     = true
}

# @param services.s3.loggingEnabled
variable "s3_logging_enabled" {
  description = "Enable access logging for S3 buckets"
  type        = bool
  default     = false
}

# @param services.s3.loggingTargetBucket
variable "s3_logging_target_bucket" {
  description = "Target bucket for S3 access logs"
  type        = string
  default     = null
}

# @param services.s3.objectOwnership
variable "s3_object_ownership" {
  description = "Object ownership setting for S3 buckets"
  type        = string
  default     = "BucketOwnerEnforced"
}

# -------------------------------------------------------------------
# ELASTICACHE
# -------------------------------------------------------------------

# @param services.elasticache.engine
variable "elasticache_engine" {
  description = "ElastiCache engine (redis, valkey, memcached)"
  type        = string
  default     = "valkey"
}

# @param services.elasticache.engineVersion
variable "elasticache_engine_version" {
  description = "ElastiCache engine version"
  type        = string
  default     = "7.2"
}

# @param services.elasticache.nodeType
variable "elasticache_node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t4g.small"
}

# @param services.elasticache.numCacheNodes
variable "elasticache_num_cache_nodes" {
  description = "Number of cache nodes (for non-cluster mode)"
  type        = number
  default     = 1
}

# @param services.elasticache.parameterGroupFamily
variable "elasticache_parameter_group_family" {
  description = "ElastiCache parameter group family"
  type        = string
  default     = "valkey7"
}

# @param services.elasticache.transitEncryption
variable "elasticache_transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

# @param services.elasticache.atRestEncryption
variable "elasticache_at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

# @param services.elasticache.authTokenEnabled
variable "elasticache_auth_token_enabled" {
  description = "Enable auth token (password) protection"
  type        = bool
  default     = true
}

# @param services.elasticache.maintenanceWindow
variable "elasticache_maintenance_window" {
  description = "Maintenance window for ElastiCache"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

# @param services.elasticache.snapshotRetentionLimit
variable "elasticache_snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 5
}

# @param services.elasticache.snapshotWindow
variable "elasticache_snapshot_window" {
  description = "Daily time range for snapshots"
  type        = string
  default     = "03:00-05:00"
}

# @param services.elasticache.automaticFailover
variable "elasticache_automatic_failover_enabled" {
  description = "Enable automatic failover (requires multiple nodes)"
  type        = bool
  default     = false
}

# @param services.elasticache.multiAz
variable "elasticache_multi_az_enabled" {
  description = "Enable Multi-AZ with automatic failover"
  type        = bool
  default     = false
}

# -------------------------------------------------------------------
# LAMBDA
# -------------------------------------------------------------------

# @param services.lambda.functionNames
variable "lambda_function_names" {
  description = "List of Lambda function names to create"
  type        = list(string)
  default     = []
}

# @param services.lambda.defaultRuntime
variable "lambda_default_runtime" {
  type        = string
  description = "Default runtime for Lambda functions"
  default     = "nodejs18.x"
}

# @param services.lambda.defaultMemory
variable "lambda_default_memory" {
  type        = number
  description = "Default memory allocation for Lambda functions (MB)"
  default     = 256
}

# @param services.lambda.defaultTimeout
variable "lambda_default_timeout" {
  type        = number
  description = "Default timeout for Lambda functions (seconds)"
  default     = 30
}

# @param services.lambda.defaultHandler
variable "lambda_default_handler" {
  type        = string
  description = "Default handler for Lambda functions"
  default     = "index.handler"
}

# @param services.lambda.ephemeralStorageSize
variable "lambda_ephemeral_storage_size" {
  type        = number
  description = "Ephemeral storage size for Lambda functions (MB)"
  default     = 512
}

# @param services.lambda.logRetentionDays
variable "lambda_log_retention_days" {
  type        = number
  description = "CloudWatch log retention period in days"
  default     = 7
}

# @param services.lambda.enableVpc
variable "lambda_enable_vpc" {
  type        = bool
  description = "Deploy Lambda functions in VPC"
  default     = false
}

# @param services.lambda.enableXrayTracing
variable "lambda_enable_xray_tracing" {
  type        = bool
  description = "Enable X-Ray tracing for Lambda functions"
  default     = false
}

# -------------------------------------------------------------------
# SQS
# -------------------------------------------------------------------

# @param services.sqs.queueNames
variable "sqs_queue_names" {
  description = "List of SQS queue names to create"
  type        = list(string)
  default     = []
}

# @param services.sqs.fifoQueues
variable "sqs_fifo_queues" {
  description = "Enable FIFO queues"
  type        = bool
  default     = false
}

# @param services.sqs.contentBasedDeduplication
variable "sqs_content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

# @param services.sqs.visibilityTimeout
variable "sqs_visibility_timeout" {
  type        = number
  description = "Visibility timeout for SQS queues (seconds)"
  default     = 30
}

# @param services.sqs.messageRetention
variable "sqs_message_retention" {
  type        = number
  description = "Message retention period for SQS queues (seconds, 60-1209600)"
  default     = 345600
}

# @param services.sqs.maxMessageSize
variable "sqs_max_message_size" {
  type        = number
  description = "Maximum message size in bytes (1024-262144)"
  default     = 262144
}

# @param services.sqs.delaySeconds
variable "sqs_delay_seconds" {
  type        = number
  description = "Delay delivery of messages (0-900 seconds)"
  default     = 0
}

# @param services.sqs.receiveWaitTime
variable "sqs_receive_wait_time" {
  type        = number
  description = "Long polling wait time (0-20 seconds)"
  default     = 0
}

# @param services.sqs.createDeadLetterQueue
variable "sqs_create_dlq" {
  description = "Create dead letter queue for each queue"
  type        = bool
  default     = false
}

# @param services.sqs.maxReceiveCount
variable "sqs_max_receive_count" {
  type        = number
  description = "Max receive count before sending to DLQ"
  default     = 3
}

# @param services.sqs.enableEncryption
variable "sqs_enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

# -------------------------------------------------------------------
# SNS
# -------------------------------------------------------------------

# @param services.sns.topicNames
variable "sns_topic_names" {
  description = "List of SNS topic names to create"
  type        = list(string)
  default     = []
}

# @param services.sns.fifoTopics
variable "sns_fifo_topics" {
  description = "Enable FIFO topics"
  type        = bool
  default     = false
}

# @param services.sns.contentBasedDeduplication
variable "sns_content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}

# @param services.sns.enableEncryption
variable "sns_enable_encryption" {
  description = "Enable encryption for SNS topics"
  type        = bool
  default     = false
}

# @param services.sns.kmsKeyId
variable "sns_kms_key_id" {
  type        = string
  description = "KMS key ID for SNS topic encryption"
  default     = null
}

# -------------------------------------------------------------------
# CLOUDFRONT
# -------------------------------------------------------------------

# @param services.cloudfront.distributionNames
variable "cloudfront_distribution_names" {
  description = "List of CloudFront distribution names/aliases to create"
  type        = list(string)
  default     = []
}

# @param services.cloudfront.priceClass
variable "cloudfront_price_class" {
  type        = string
  description = "Price class for CloudFront distributions"
  default     = "PriceClass_100"
}

# @param services.cloudfront.enableIpv6
variable "cloudfront_enable_ipv6" {
  type        = bool
  description = "Enable IPv6 for CloudFront distributions"
  default     = true
}

# @param services.cloudfront.enableWaf
variable "cloudfront_enable_waf" {
  type        = bool
  description = "Enable WAF for CloudFront distributions"
  default     = false
}

# @param services.cloudfront.enableLogging
variable "cloudfront_enable_logging" {
  type        = bool
  description = "Enable access logging for CloudFront distributions"
  default     = false
}

# @param services.cloudfront.loggingBucket
variable "cloudfront_logging_bucket" {
  type        = string
  description = "S3 bucket for CloudFront access logs"
  default     = null
}

# -------------------------------------------------------------------
# ROUTE53
# -------------------------------------------------------------------

# @param services.route53.zoneNames
variable "route53_zone_names" {
  description = "List of Route53 hosted zone domain names to create"
  type        = list(string)
  default     = []
}

# @param services.route53.privateZones
variable "route53_private_zones" {
  description = "Create private hosted zones (VPC-associated)"
  type        = bool
  default     = false
}

# @param services.route53.forceDestroy
variable "route53_force_destroy" {
  description = "Allow deletion of zones with records"
  type        = bool
  default     = false
}

# @param services.route53.enableDnssec
variable "route53_enable_dnssec" {
  description = "Enable DNSSEC for hosted zones"
  type        = bool
  default     = false
}


