# @section services.s3.enabled begin
module "s3_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.8"

  for_each = toset(var.s3_bucket_names)

  bucket = "${var.global_prefix}-${each.value}-${var.environment_short}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  tags = merge({
    Name = each.value
  }, var.global_tags)
}
# @section services.s3.enabled end
