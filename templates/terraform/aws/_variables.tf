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

variable "default_node_group_nodes_count" {
  type        = number
  description = "Count of nodes in default node group (deprecated, use min/max/desired instead)"
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

variable "rds_create_db_subnet_group" {
  type        = bool
  description = "Whether to create DB subnet group"
  default     = true
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

variable "rds_create_db_option_group" {
  type        = bool
  description = "Whether to create DB option group"
  default     = true
}

variable "rds_create_db_parameter_group" {
  type        = bool
  description = "Whether to create DB parameter group"
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

variable "rds_storage_encrypted" {
  type        = bool
  description = "Enable storage encryption"
  default     = true
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

variable "rds_create_monitoring_role" {
  type        = bool
  description = "Whether to create monitoring IAM role"
  default     = true
}

variable "rds_monitoring_interval" {
  type        = number
  description = "Monitoring interval in seconds"
  default     = 60
}

variable "rds_create_cloudwatch_log_group" {
  type        = bool
  description = "Whether to create CloudWatch log group"
  default     = true
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

variable "aurora_instance_class" {
  type        = string
  default     = "db.serverless"
  description = "The instance class for the Aurora serverless database (e.g., db.serverless)"
}

variable "aurora_engine_mode" {
  type        = string
  description = "Engine mode for Aurora cluster"
  default     = "provisioned"
}

variable "aurora_instances" {
  type        = map(any)
  description = "Map of Aurora instances"
  default     = {
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

variable "aurora_create_db_subnet_group" {
  type        = bool
  description = "Whether to create DB subnet group for Aurora"
  default     = true
}

variable "aurora_enable_http_endpoint" {
  type        = bool
  description = "Enable HTTP endpoint for Aurora"
  default     = true
}

variable "aurora_manage_master_user_password" {
  type        = bool
  description = "Whether Aurora manages the master user password"
  default     = false
}

variable "aurora_storage_encrypted" {
  type        = bool
  description = "Enable storage encryption for Aurora"
  default     = true
}

variable "aurora_iam_database_authentication_enabled" {
  type        = bool
  description = "Enable IAM database authentication for Aurora"
  default     = true
}

variable "aurora_create_monitoring_role" {
  type        = bool
  description = "Whether to create monitoring IAM role for Aurora"
  default     = true
}

variable "aurora_monitoring_interval" {
  type        = number
  description = "Monitoring interval in seconds for Aurora"
  default     = 60
}

variable "aurora_create_cloudwatch_log_group" {
  type        = bool
  description = "Whether to create CloudWatch log group for Aurora"
  default     = true
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
  default     = {
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
