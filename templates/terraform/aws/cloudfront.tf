# @section services.cloudfront.enabled begin
## Note: CloudFront distributions require custom origin configuration
## This is a basic setup - customize origins and behaviors based on your needs

locals {
  cloudfront_create_logs_bucket  = var.cloudfront_enable_logging && (var.cloudfront_logging_bucket == null || var.cloudfront_logging_bucket == "")
  cloudfront_logging_bucket_name = local.cloudfront_create_logs_bucket ? module.cloudfront_logs_bucket[0].s3_bucket_id : var.cloudfront_logging_bucket
}

module "cloudfront_origin_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.15"

  for_each = toset(var.cloudfront_distribution_names)

  bucket = "${var.global_prefix}${replace(each.value, ".", "-")}-origin-${var.environment}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  tags = merge({
    Name = each.value
  }, var.global_tags)
}

data "aws_iam_policy_document" "cloudfront_origin" {
  for_each = toset(var.cloudfront_distribution_names)

  statement {
    sid       = "AllowCloudFrontServicePrincipalReadOnly"
    actions   = ["s3:GetObject"]
    resources = ["${module.cloudfront_origin_buckets[each.value].s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront_distributions[each.value].cloudfront_distribution_arn]
    }
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      module.cloudfront_origin_buckets[each.value].s3_bucket_arn,
      "${module.cloudfront_origin_buckets[each.value].s3_bucket_arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_origin" {
  for_each = toset(var.cloudfront_distribution_names)

  bucket = module.cloudfront_origin_buckets[each.value].s3_bucket_id
  policy = data.aws_iam_policy_document.cloudfront_origin[each.value].json
}

module "cloudfront_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.15"

  count = local.cloudfront_create_logs_bucket ? 1 : 0

  bucket        = "${var.global_prefix}cloudfront-logs-${var.environment}"
  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  attach_deny_insecure_transport_policy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  tags = var.global_tags
}

module "cloudfront_distributions" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 6.7"

  for_each = toset(var.cloudfront_distribution_names)

  comment             = "CloudFront distribution for ${each.value}"
  enabled             = true
  is_ipv6_enabled     = var.cloudfront_enable_ipv6
  price_class         = var.cloudfront_price_class
  retain_on_delete    = false
  wait_for_deployment = true

  origin_access_control = {
    s3 = {
      name             = "${var.global_prefix}${replace(each.value, ".", "-")}-${var.environment}"
      description      = "CloudFront access to the ${each.value} origin bucket"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    default = {
      domain_name               = module.cloudfront_origin_buckets[each.value].s3_bucket_bucket_regional_domain_name
      origin_id                 = each.value
      origin_access_control_key = "s3"
    }
  }

  default_cache_behavior = {
    target_origin_id       = each.value
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  restrictions = {
    geo_restriction = {
      restriction_type = "none"
    }
  }

  # @section services.waf.enabled begin
  web_acl_id = var.cloudfront_enable_waf ? aws_wafv2_web_acl.cloudfront[0].arn : null
  # @section services.waf.enabled end

  logging_config = var.cloudfront_enable_logging ? {
    bucket          = "${local.cloudfront_logging_bucket_name}.s3.amazonaws.com"
    prefix          = "cloudfront/"
    include_cookies = false
  } : null

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.cloudfront.enabled end
