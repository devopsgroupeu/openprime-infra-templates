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

variable "s3_buckets" {
  description = "List of S3 buckets to create with their configurations"
  type = list(object({
    name                     = string
    versioning_enabled       = optional(bool, false)
    encryption_type          = optional(string, "AES256")
    kms_key_id               = optional(string, null)
    bucket_key_enabled       = optional(bool, true)
    block_public_acls        = optional(bool, true)
    block_public_policy      = optional(bool, true)
    ignore_public_acls       = optional(bool, true)
    restrict_public_buckets  = optional(bool, true)
    logging_enabled          = optional(bool, false)
    logging_target_bucket    = optional(string, null)
    logging_prefix           = optional(string, "logs/")
    control_object_ownership = optional(bool, true)
    object_ownership         = optional(string, "BucketOwnerEnforced")
    attach_policy            = optional(bool, false)
    policy                   = optional(string, null)
    lifecycle_rules          = optional(list(any), [])
    cors_rules               = optional(list(any), [])
  }))
  default = []
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

variable "lambda_functions" {
  description = "List of Lambda functions to create"
  type = list(object({
    name                           = string
    description                    = optional(string, null)
    handler                        = optional(string, "index.handler")
    runtime                        = optional(string, null)
    memory_size                    = optional(number, null)
    timeout                        = optional(number, null)
    ephemeral_storage_size         = optional(number, 512)
    package_path                   = optional(string, null)
    s3_bucket                      = optional(string, null)
    s3_key                         = optional(string, null)
    create_package                 = optional(bool, false)
    environment_variables          = optional(map(string), {})
    vpc_subnet_ids                 = optional(list(string), null)
    vpc_security_group_ids         = optional(list(string), null)
    create_role                    = optional(bool, true)
    role_name                      = optional(string, null)
    attach_cloudwatch_logs_policy  = optional(bool, true)
    layers                         = optional(list(string), [])
    reserved_concurrent_executions = optional(number, -1)
    dlq_arn                        = optional(string, null)
    tracing_mode                   = optional(string, "PassThrough")
    log_retention_days             = optional(number, 7)
  }))
  default = []
}

variable "lambda_default_runtime" {
  type        = string
  description = "Default runtime for Lambda functions"
  default     = "nodejs18.x"
}

variable "lambda_default_memory" {
  type        = number
  description = "Default memory allocation for Lambda functions (MB)"
  default     = 256
}

variable "lambda_default_timeout" {
  type        = number
  description = "Default timeout for Lambda functions (seconds)"
  default     = 30
}

# -------------------------------------------------------------------
# SQS
# -------------------------------------------------------------------

variable "sqs_queues" {
  description = "List of SQS queues to create"
  type = list(object({
    name                              = string
    fifo_queue                        = optional(bool, false)
    content_based_deduplication       = optional(bool, false)
    deduplication_scope               = optional(string, "queue")
    fifo_throughput_limit             = optional(string, "perQueue")
    visibility_timeout_seconds        = optional(number, null)
    message_retention_seconds         = optional(number, null)
    max_message_size                  = optional(number, 262144)
    delay_seconds                     = optional(number, 0)
    receive_wait_time_seconds         = optional(number, 0)
    create_dlq                        = optional(bool, false)
    dlq_message_retention_seconds     = optional(number, 1209600)
    max_receive_count                 = optional(number, 3)
    sse_enabled                       = optional(bool, true)
    kms_key_id                        = optional(string, null)
    kms_data_key_reuse_period_seconds = optional(number, 300)
  }))
  default = []
}

variable "sqs_default_visibility_timeout" {
  type        = number
  description = "Default visibility timeout for SQS queues (seconds)"
  default     = 30
}

variable "sqs_default_message_retention" {
  type        = number
  description = "Default message retention period for SQS queues (seconds)"
  default     = 345600
}

# -------------------------------------------------------------------
# SNS
# -------------------------------------------------------------------

variable "sns_topics" {
  description = "List of SNS topics to create"
  type = list(object({
    name                        = string
    display_name                = optional(string, null)
    kms_master_key_id           = optional(string, null)
    delivery_policy             = optional(string, null)
    subscriptions               = optional(map(any), {})
    fifo_topic                  = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    data_protection_policy      = optional(string, null)
  }))
  default = []
}

variable "sns_default_kms_key_id" {
  type        = string
  description = "Default KMS key ID for SNS topic encryption"
  default     = null
}

# -------------------------------------------------------------------
# CLOUDFRONT
# -------------------------------------------------------------------

variable "cloudfront_distributions" {
  description = "List of CloudFront distributions to create"
  type = list(object({
    name                    = string
    comment                 = optional(string, null)
    enabled                 = optional(bool, true)
    is_ipv6_enabled         = optional(bool, true)
    price_class             = optional(string, null)
    retain_on_delete        = optional(bool, false)
    wait_for_deployment     = optional(bool, true)
    default_origin_id       = optional(string, "default")
    origins                 = optional(list(any), [])
    default_cache_behavior  = optional(map(any), {})
    ordered_cache_behaviors = optional(list(any), [])
    viewer_certificate      = optional(map(any), {})
    geo_restriction         = optional(map(any), {})
    web_acl_id              = optional(string, null)
    custom_error_responses  = optional(list(any), [])
    logging_enabled         = optional(bool, false)
    logging_bucket          = optional(string, null)
    logging_prefix          = optional(string, "cloudfront/")
    logging_include_cookies = optional(bool, false)
  }))
  default = []
}

variable "cloudfront_default_price_class" {
  type        = string
  description = "Default price class for CloudFront distributions"
  default     = "PriceClass_100"
}

variable "cloudfront_default_waf_enabled" {
  type        = bool
  description = "Whether to enable WAF by default for CloudFront distributions"
  default     = false
}

# -------------------------------------------------------------------
# ROUTE53
# -------------------------------------------------------------------

# @param services.route53.hostedZones
variable "route53_hosted_zones" {
  description = "List of Route53 hosted zones to create with their records"
  type = list(object({
    name              = string
    comment           = optional(string, null)
    vpc_id            = optional(string, null)
    vpc_region        = optional(string, null)
    force_destroy     = optional(bool, false)
    delegation_set_id = optional(string, null)
    enable_dnssec     = optional(bool, false)

    # Records within this zone
    records = optional(map(object({
      name            = optional(string)
      full_name       = optional(string)
      type            = string
      ttl             = optional(number, 300)
      records         = optional(list(string), [])
      set_identifier  = optional(string, null)
      allow_overwrite = optional(bool, false)
      health_check_id = optional(string, null)

      # Alias configuration
      alias = optional(object({
        name                   = string
        zone_id                = string
        evaluate_target_health = optional(bool, false)
      }), null)

      # Weighted routing
      weighted_routing_policy = optional(object({
        weight = number
      }), null)

      # Geolocation routing
      geolocation_routing_policy = optional(object({
        continent   = optional(string)
        country     = optional(string)
        subdivision = optional(string)
      }), null)

      # Geoproximity routing
      geoproximity_routing_policy = optional(object({
        aws_region       = optional(string)
        bias             = optional(number)
        local_zone_group = optional(string)
        coordinates = optional(list(object({
          latitude  = number
          longitude = number
        })))
      }), null)

      # Failover routing
      failover_routing_policy = optional(object({
        type = string
      }), null)

      # Latency routing
      latency_routing_policy = optional(object({
        region = string
      }), null)

      # CIDR routing
      cidr_routing_policy = optional(object({
        collection_id = string
        location_name = string
      }), null)

      # Multivalue answer
      multivalue_answer_routing_policy = optional(bool, null)
    })), {})
  }))
  default = []
}


