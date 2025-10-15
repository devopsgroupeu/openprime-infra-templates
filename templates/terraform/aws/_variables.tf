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

# -------------------------------------------------------------------
# EKS
# -------------------------------------------------------------------

variable "default_node_group_ami_type" {
  type        = string
  description = "AMI type of default node group"
  default     = "BOTTLEROCKET_x86_64"
}

variable "default_node_group_instance_type" {
  type        = string
  description = "Instance type of default node group"
  default     = "m5.large"
}

variable "default_node_group_nodes_count" {
  type        = number
  description = "Count of nodes in default node group"
  default     = 2
}

variable "default_node_group_capacity_type" {
  type        = string
  description = "Capacity type of default node group"
  default     = "ON_DEMAND"
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
  default     = "serverless.v2"
  description = "The instance class for the Aurora serverless database (e.g., serverless.v2)"
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
