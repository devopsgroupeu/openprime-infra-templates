# @section services.sns.enabled begin
module "sns_topics" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 6.0"

  for_each = { for idx, topic in var.sns_topics : topic.name => topic }

  name         = "${var.global_prefix}${each.value.name}-${var.environment_short}"
  display_name = lookup(each.value, "display_name", each.value.name)

  # Encryption
  kms_master_key_id = lookup(each.value, "kms_master_key_id", var.sns_default_kms_key_id)

  # Delivery policy
  delivery_policy = lookup(each.value, "delivery_policy", null)

  # Subscriptions
  subscriptions = lookup(each.value, "subscriptions", {})

  # FIFO topics
  fifo_topic                  = lookup(each.value, "fifo_topic", false)
  content_based_deduplication = lookup(each.value, "content_based_deduplication", false)

  # Data protection policy
  data_protection_policy = lookup(each.value, "data_protection_policy", null)

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}
# @section services.sns.enabled end
