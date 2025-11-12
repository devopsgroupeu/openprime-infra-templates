# @section services.sqs.enabled begin
module "sqs_queues" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 5.1"

  for_each = { for idx, queue in var.sqs_queues : queue.name => queue }

  name = "${var.global_prefix}${each.value.name}-${var.environment_short}"

  fifo_queue                  = lookup(each.value, "fifo_queue", false)
  content_based_deduplication = lookup(each.value, "content_based_deduplication", false)
  deduplication_scope         = lookup(each.value, "fifo_queue", false) ? lookup(each.value, "deduplication_scope", "queue") : null
  fifo_throughput_limit       = lookup(each.value, "fifo_queue", false) ? lookup(each.value, "fifo_throughput_limit", "perQueue") : null

  ## Message settings
  visibility_timeout_seconds = lookup(each.value, "visibility_timeout_seconds", var.sqs_default_visibility_timeout)
  message_retention_seconds  = lookup(each.value, "message_retention_seconds", var.sqs_default_message_retention)
  max_message_size           = lookup(each.value, "max_message_size", 262144)
  delay_seconds              = lookup(each.value, "delay_seconds", 0)
  receive_wait_time_seconds  = lookup(each.value, "receive_wait_time_seconds", 0)

  ## Dead letter queue
  create_dlq                    = lookup(each.value, "create_dlq", false)
  dlq_name                      = lookup(each.value, "create_dlq", false) ? "${var.global_prefix}${each.value.name}-dlq-${var.environment_short}" : null
  dlq_message_retention_seconds = lookup(each.value, "dlq_message_retention_seconds", 1209600)
  redrive_policy = lookup(each.value, "create_dlq", false) ? {
    maxReceiveCount = lookup(each.value, "max_receive_count", 3)
  } : null

  ## Encryption
  sqs_managed_sse_enabled           = lookup(each.value, "sse_enabled", true)
  kms_master_key_id                 = lookup(each.value, "kms_key_id", null)
  kms_data_key_reuse_period_seconds = lookup(each.value, "kms_data_key_reuse_period_seconds", 300)

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}
# @section services.sqs.enabled end
