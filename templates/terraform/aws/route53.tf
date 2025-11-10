# @section services.route53.enabled begin
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  for_each = { for idx, zone in var.route53_hosted_zones : zone.name => zone }

  zones = {
    (each.value.name) = {
      comment = lookup(each.value, "comment", "Hosted zone for ${each.value.name}")
      vpc = lookup(each.value, "vpc_id", null) != null ? [
        {
          vpc_id     = lookup(each.value, "vpc_id", null)
          vpc_region = lookup(each.value, "vpc_region", var.region)
        }
      ] : []
    }
  }

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}

module "route53_records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  depends_on = [module.route53_zones]

  for_each = { for idx, record in var.route53_record_sets : "${record.zone_name}-${record.name}-${record.type}" => record }

  zone_id = try(
    module.route53_zones[each.value.zone_name].route53_zone_zone_id[each.value.zone_name],
    lookup(each.value, "zone_id", null)
  )

  records = [
    {
      name    = lookup(each.value, "name", "")
      type    = lookup(each.value, "type", "A")
      ttl     = lookup(each.value, "ttl", 300)
      records = lookup(each.value, "records", [])

      # Alias records
      alias = lookup(each.value, "alias_name", null) != null ? {
        name                   = lookup(each.value, "alias_name", null)
        zone_id                = lookup(each.value, "alias_zone_id", null)
        evaluate_target_health = lookup(each.value, "alias_evaluate_target_health", false)
      } : null

      # Weighted routing policy
      set_identifier = lookup(each.value, "set_identifier", null)
      weighted_routing_policy = lookup(each.value, "weight", null) != null ? {
        weight = lookup(each.value, "weight", null)
      } : null

      # Geolocation routing policy
      geolocation_routing_policy = lookup(each.value, "continent", null) != null || lookup(each.value, "country", null) != null ? {
        continent   = lookup(each.value, "continent", null)
        country     = lookup(each.value, "country", null)
        subdivision = lookup(each.value, "subdivision", null)
      } : null

      # Failover routing policy
      failover_routing_policy = lookup(each.value, "failover", null) != null ? {
        type = lookup(each.value, "failover", null)
      } : null

      # Health check
      health_check_id = lookup(each.value, "health_check_id", null)
    }
  ]
}
# @section services.route53.enabled end
