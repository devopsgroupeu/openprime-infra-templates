# @section services.cloudfront.enabled begin
## Note: CloudFront distributions require custom origin configuration
## This is a basic setup - customize origins and behaviors based on your needs
module "cloudfront_distributions" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 5.0"

  for_each = toset(var.cloudfront_distribution_names)

  comment             = "CloudFront distribution for ${each.value}"
  enabled             = true
  is_ipv6_enabled     = var.cloudfront_enable_ipv6
  price_class         = var.cloudfront_price_class
  retain_on_delete    = false
  wait_for_deployment = true

  ## Basic S3 origin example
  origin = {
    default = {
      domain_name = "${each.value}.s3.amazonaws.com"
      origin_id   = each.value
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

  geo_restriction = {
    restriction_type = "none"
  }

  web_acl_id = var.cloudfront_enable_waf ? try(aws_wafv2_web_acl.waf, null) : null

  logging_config = var.cloudfront_enable_logging ? {
    bucket          = "${var.cloudfront_logging_bucket}.s3.amazonaws.com"
    prefix          = "cloudfront/"
    include_cookies = false
  } : null

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.cloudfront.enabled end
