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
  version = "~> 3.1"

  for_each = toset(var.ecr_repository_names)

  repository_type                 = var.ecr_repository_type
  repository_name                 = each.value
  repository_encryption_type      = var.ecr_encryption_type
  repository_image_tag_mutability = var.ecr_image_tag_mutability

  ## Lifecycle policy configuration
  create_lifecycle_policy = var.ecr_create_lifecycle_policy
  repository_lifecycle_policy = var.ecr_create_lifecycle_policy ? jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last ${var.ecr_lifecycle_policy_max_images} images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = var.ecr_lifecycle_policy_max_images
        },
        action = {
          type = "expire"
        }
      }
    ]
  }) : null

  tags = merge({
    "Name" = each.value
  }, var.global_tags)

  depends_on = [module.ecr_registry]
}

module "ecr_registry" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.1"

  create_repository = false

  ## Registry Policy
  create_registry_policy = var.ecr_enable_replication
  registry_policy        = var.ecr_enable_replication ? data.aws_iam_policy_document.ecr_registry_replication[0].json : null

  ## Registry Scanning Configuration
  manage_registry_scanning_configuration = var.ecr_enable_scanning
  registry_scan_type                     = var.ecr_scan_type

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

  tags = var.global_tags
}
# @section services.ecr.enabled end
