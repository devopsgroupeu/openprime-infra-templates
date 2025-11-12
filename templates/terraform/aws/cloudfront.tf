# @section services.cloudfront.enabled begin
module "cloudfront_distributions" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 5.0"

  for_each = { for idx, dist in var.cloudfront_distributions : dist.name => dist }

  comment             = lookup(each.value, "comment", "CloudFront distribution for ${each.value.name}")
  enabled             = lookup(each.value, "enabled", true)
  is_ipv6_enabled     = lookup(each.value, "is_ipv6_enabled", true)
  price_class         = lookup(each.value, "price_class", var.cloudfront_default_price_class)
  retain_on_delete    = lookup(each.value, "retain_on_delete", false)
  wait_for_deployment = lookup(each.value, "wait_for_deployment", true)

  origin = lookup(each.value, "origins", [])

  default_cache_behavior = lookup(each.value, "default_cache_behavior", {
    target_origin_id       = lookup(each.value, "default_origin_id", "default")
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  })

  ordered_cache_behavior = lookup(each.value, "ordered_cache_behaviors", [])

  viewer_certificate = lookup(each.value, "viewer_certificate", {
    cloudfront_default_certificate = true
  })

  geo_restriction = lookup(each.value, "geo_restriction", {
    restriction_type = "none"
  })

  web_acl_id = lookup(each.value, "web_acl_id", var.cloudfront_default_waf_enabled ? aws_wafv2_web_acl.waf : null)

  custom_error_response = lookup(each.value, "custom_error_responses", [])

  logging_config = lookup(each.value, "logging_enabled", false) ? {
    bucket          = lookup(each.value, "logging_bucket", null)
    prefix          = lookup(each.value, "logging_prefix", "cloudfront/")
    include_cookies = lookup(each.value, "logging_include_cookies", false)
  } : null

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}
# @section services.cloudfront.enabled end
