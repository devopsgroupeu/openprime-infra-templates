# @section services.lambda.enabled begin
module "lambda_functions" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.1"

  for_each = toset(var.lambda_function_names)

  function_name = "${var.global_prefix}-${each.value}-${var.environment_short}"
  description   = "Lambda function ${each.value}"
  handler       = "index.handler"
  runtime       = "nodejs24.x"

  ## Source code - requires external package
  create_package         = false
  local_existing_package = "${path.module}/lambda-packages/${each.value}.zip"

  ## Resources
  memory_size            = 256
  timeout                = 30
  ephemeral_storage_size = 512

  ## IAM
  create_role                   = true
  role_name                     = "${var.global_prefix}-${each.value}-lambda-role"
  attach_cloudwatch_logs_policy = true

  cloudwatch_logs_retention_in_days = 7

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.lambda.enabled end
