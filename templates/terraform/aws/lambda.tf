# @section services.lambda.enabled begin
module "lambda_functions" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  for_each = { for idx, func in var.lambda_functions : func.name => func }

  function_name = "${var.global_prefix}${each.value.name}-${var.environment_short}"
  description   = lookup(each.value, "description", "Lambda function ${each.value.name}")
  handler       = lookup(each.value, "handler", "index.handler")
  runtime       = lookup(each.value, "runtime", var.lambda_default_runtime)

  # Source code
  create_package         = lookup(each.value, "create_package", false)
  local_existing_package = lookup(each.value, "package_path", null)
  s3_existing_package = lookup(each.value, "s3_bucket", null) != null ? {
    bucket = lookup(each.value, "s3_bucket", null)
    key    = lookup(each.value, "s3_key", null)
  } : null

  # Resources
  memory_size            = lookup(each.value, "memory_size", var.lambda_default_memory)
  timeout                = lookup(each.value, "timeout", var.lambda_default_timeout)
  ephemeral_storage_size = lookup(each.value, "ephemeral_storage_size", 512)

  # Environment variables
  environment_variables = lookup(each.value, "environment_variables", {})

  # VPC configuration
  vpc_subnet_ids         = lookup(each.value, "vpc_subnet_ids", null)
  vpc_security_group_ids = lookup(each.value, "vpc_security_group_ids", null)

  # IAM
  create_role                   = lookup(each.value, "create_role", true)
  role_name                     = lookup(each.value, "role_name", "${var.global_prefix}${each.value.name}-lambda-role")
  attach_cloudwatch_logs_policy = lookup(each.value, "attach_cloudwatch_logs_policy", true)
  attach_network_policy         = lookup(each.value, "vpc_subnet_ids", null) != null ? true : false

  # Layers
  layers = lookup(each.value, "layers", [])

  # Reserved concurrent executions
  reserved_concurrent_executions = lookup(each.value, "reserved_concurrent_executions", -1)

  # Dead letter queue
  dead_letter_target_arn = lookup(each.value, "dlq_arn", null)

  # Tracing
  tracing_mode = lookup(each.value, "tracing_mode", "PassThrough")

  # CloudWatch Logs
  cloudwatch_logs_retention_in_days = lookup(each.value, "log_retention_days", 7)

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}
# @section services.lambda.enabled end
