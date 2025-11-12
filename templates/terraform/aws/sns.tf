# @section services.sns.enabled begin
module "sns_topics" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 7.0"

  for_each = toset(var.sns_topic_names)

  name         = "${var.global_prefix}-${each.value}-${var.environment_short}"
  display_name = each.value

  kms_master_key_id = var.sns_enable_encryption ? var.sns_kms_key_id : null

  delivery_policy = null
  subscriptions   = {}

  fifo_topic                  = var.sns_fifo_topics
  content_based_deduplication = var.sns_content_based_deduplication

  data_protection_policy = null

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.sns.enabled end
