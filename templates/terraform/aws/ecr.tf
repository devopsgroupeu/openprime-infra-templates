# @section services.ecr.enabled begin
## IAM Policy Document for ECR Registry Replication
data "aws_iam_policy_document" "ecr_registry_replication" {
  count = var.ecr_enable_replication ? 1 : 0

  statement {
    sid    = "AllowCrossRegionReplication"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "ecr:ReplicateImage"
    ]

    resources = [
      "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.4"

  for_each                          = toset(var.ecr_repositories)
  repository_type                   = var.ecr_repository_type
  repository_name                   = each.value
  repository_read_write_access_arns = var.ecr_repository_read_write_access_arns
  repository_encryption_type        = var.ecr_repository_encryption_type
  repository_image_tag_mutability   = var.ecr_image_tag_mutability

  ## Image scanning configuration
  repository_image_scan_on_push = var.ecr_enable_scanning

  create_lifecycle_policy = var.ecr_create_lifecycle_policy
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = var.ecr_lifecycle_policy_rule_priority,
        description  = var.ecr_lifecycle_policy_description,
        selection = {
          tagStatus     = var.ecr_lifecycle_policy_tag_status,
          tagPrefixList = var.ecr_lifecycle_policy_tag_prefix_list,
          countType     = var.ecr_lifecycle_policy_count_type,
          countNumber   = var.ecr_lifecycle_policy_count_number
        },
        action = {
          type = var.ecr_lifecycle_policy_action_type
        }
      }
    ]
  })

  tags = merge({
    "Name" = each.value
  }, var.global_tags)

  depends_on = [module.ecr_registry]
}

module "ecr_registry" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.4"

  create_repository = false

  ## Registry Policy
  create_registry_policy = var.ecr_enable_replication
  registry_policy        = var.ecr_enable_replication ? data.aws_iam_policy_document.ecr_registry_replication[0].json : null

  ## Registry Scanning Configuration
  manage_registry_scanning_configuration = var.ecr_enable_scanning
  registry_scan_type                     = var.ecr_enable_scanning ? var.ecr_scan_type : "BASIC"
  registry_scan_rules = var.ecr_enable_scanning ? [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter = [{
        filter      = "*"
        filter_type = "WILDCARD"
      }]
    }
  ] : []

  ## Registry Replication Configuration
  create_registry_replication_configuration = var.ecr_enable_replication && length(var.ecr_replication_destinations) > 0
  registry_replication_rules = var.ecr_enable_replication && length(var.ecr_replication_destinations) > 0 ? [
    {
      destinations = [
        for region in var.ecr_replication_destinations : {
          region      = region
          registry_id = data.aws_caller_identity.current.account_id
        }
      ]
      repository_filters = [{
        filter      = "*"
        filter_type = "WILDCARD"
      }]
    }
  ] : []

  tags = merge({
    "Name" = "${var.global_prefix}-ecr-registry"
  }, var.global_tags)
}
# @section services.ecr.enabled end
