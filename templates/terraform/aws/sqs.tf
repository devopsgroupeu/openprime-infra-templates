# @section services.sqs.enabled begin
module "sqs_queues" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 5.1"

  for_each = toset(var.sqs_queue_names)

  name = "${var.global_prefix}-${each.value}-${var.environment_short}"

  fifo_queue                  = var.sqs_fifo_queues
  content_based_deduplication = var.sqs_content_based_deduplication
  deduplication_scope         = var.sqs_fifo_queues ? "queue" : null
  fifo_throughput_limit       = var.sqs_fifo_queues ? "perQueue" : null

  ## Message settings
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time

  ## Dead letter queue
  create_dlq                    = var.sqs_create_dlq
  dlq_name                      = var.sqs_create_dlq ? "${var.global_prefix}-${each.value}-dlq-${var.environment_short}" : null
  dlq_message_retention_seconds = 1209600
  redrive_policy = var.sqs_create_dlq ? {
    maxReceiveCount = var.sqs_max_receive_count
  } : null

  ## Encryption
  sqs_managed_sse_enabled           = var.sqs_enable_encryption
  kms_master_key_id                 = null
  kms_data_key_reuse_period_seconds = 300

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.sqs.enabled end
