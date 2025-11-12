# @section services.s3.enabled begin
module "s3_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  for_each = { for idx, bucket in var.s3_buckets : bucket.name => bucket }

  bucket = "${var.global_prefix}${each.value.name}-${var.environment_short}"

  block_public_acls       = lookup(each.value, "block_public_acls", true)
  block_public_policy     = lookup(each.value, "block_public_policy", true)
  ignore_public_acls      = lookup(each.value, "ignore_public_acls", true)
  restrict_public_buckets = lookup(each.value, "restrict_public_buckets", true)

  versioning = {
    enabled = lookup(each.value, "versioning_enabled", false)
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = lookup(each.value, "encryption_type", "AES256")
        kms_master_key_id = lookup(each.value, "encryption_type", "AES256") == "aws:kms" ? lookup(each.value, "kms_key_id", null) : null
      }
      bucket_key_enabled = lookup(each.value, "bucket_key_enabled", true)
    }
  }

  lifecycle_rule = lookup(each.value, "lifecycle_rules", [])

  logging = lookup(each.value, "logging_enabled", false) ? {
    target_bucket = lookup(each.value, "logging_target_bucket", null)
    target_prefix = lookup(each.value, "logging_prefix", "logs/")
  } : {}

  cors_rule = lookup(each.value, "cors_rules", [])

  control_object_ownership = lookup(each.value, "control_object_ownership", true)
  object_ownership         = lookup(each.value, "object_ownership", "BucketOwnerEnforced")

  attach_policy = lookup(each.value, "attach_policy", false)
  policy        = lookup(each.value, "policy", null)

  tags = merge({
    Name = each.value.name
  }, var.global_tags)
}
# @section services.s3.enabled end
