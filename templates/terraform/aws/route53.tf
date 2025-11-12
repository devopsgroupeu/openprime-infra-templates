# @section services.route53.enabled begin
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws"
  version = "~> 6.1"

  for_each = { for idx, zone in var.route53_hosted_zones : zone.name => zone }

  create_zone = true
  name        = each.value.name
  comment     = lookup(each.value, "comment", "Managed by Terraform - Hosted zone for ${each.value.name}")

  ## Private zone configuration
  vpc = lookup(each.value, "vpc_id", null) != null ? {
    default = {
      vpc_id     = lookup(each.value, "vpc_id")
      vpc_region = lookup(each.value, "vpc_region", var.region)
    }
  } : null

  force_destroy = lookup(each.value, "force_destroy", false)

  ## Delegation set (for public zones only)
  delegation_set_id = lookup(each.value, "delegation_set_id", null)

  enable_dnssec = lookup(each.value, "enable_dnssec", false)
  records       = lookup(each.value, "records", {})

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}
# @section services.route53.enabled end
