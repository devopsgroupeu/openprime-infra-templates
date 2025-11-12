# @section services.route53.enabled begin
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws"
  version = "~> 6.1"

  for_each = toset(var.route53_zone_names)

  create_zone = true
  name        = each.value
  comment     = "Managed by Terraform - Hosted zone for ${each.value}"

  ## Private zone configuration
  vpc = var.route53_private_zones ? {
    default = {
      vpc_id     = module.vpc.vpc_id
      vpc_region = var.region
    }
  } : null

  force_destroy = var.route53_force_destroy

  ## Delegation set (for public zones only)
  delegation_set_id = null

  enable_dnssec = var.route53_enable_dnssec
  records       = {}

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.route53.enabled end
