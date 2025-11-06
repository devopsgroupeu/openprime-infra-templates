# @section services.opensearch.enabled begin
module "opensearch" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "~> 2.0"

  domain_name          = var.opensearch_domain_name
  engine_version       = var.opensearch_version
  create_access_policy = var.opensearch_create_access_policy
  ip_address_type      = var.opensearch_ip_address_type

  cluster_config = {
    instance_count = var.opensearch_instance_count
    instance_type  = var.opensearch_instance_type
  }

  ebs_options = {
    ebs_enabled = var.opensearch_ebs_enabled
    volume_type = var.opensearch_ebs_volume_type
    volume_size = var.opensearch_ebs_volume_size
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = var.opensearch_allow_explicit_index
  }

  domain_endpoint_options = {
    custom_endpoint_enabled         = var.opensearch_custom_endpoint_enabled
    custom_endpoint                 = var.opensearch_custom_endpoint
    custom_endpoint_certificate_arn = var.opensearch_acm_certificate_arn
    enforce_https                   = var.opensearch_enforce_https
    tls_security_policy             = var.opensearch_tls_security_policy
  }

  advanced_security_options = {
    enabled                        = var.opensearch_advanced_security_enabled
    internal_user_database_enabled = var.opensearch_internal_user_database_enabled
    master_user_options = {
      master_user_name     = var.opensearch_master_user_name
      master_user_password = var.opensearch_master_user_password != "" ? var.opensearch_master_user_password : random_password.opensearch_master_user_password.result
    }
  }
}

resource "random_password" "opensearch_master_user_password" {
  length = 16

  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}
# @section services.opensearch.enabled end
