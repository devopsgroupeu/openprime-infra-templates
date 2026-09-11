# No separator dash below: global_prefix already ends in one (mandatory per
# _variables.tf's validation, OP-231) - the same no-double-hyphen convention
# database.tf and elasticache.tf follow. This comment has to live outside the
# @section block, not next to the line it explains - Injecto's section
# toggling strips one leading "#" from every line in an enabled section
# (src/processing.py, Pass 1), so a comment placed inside becomes bare
# invalid text once the section is enabled.
# @section services.s3.enabled begin
module "s3_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.15"

  for_each = toset(var.s3_bucket_names)

  bucket = "${var.global_prefix}${each.value}-${var.environment}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled = var.s3_versioning_enabled
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
