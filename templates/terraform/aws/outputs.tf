# @section services.eks.enabled begin
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
# @section services.eks.enabled end

# @section services.opensearch.enabled begin
output "opensearch_master_user_password" {
  value       = try(var.opensearch_master_user_password != "" ? var.opensearch_master_user_password : random_password.opensearch_master_user_password.result, "")
  description = "Master password."
  sensitive   = true
}

output "opensearch_master_user_name" {
  value       = try(var.opensearch_master_user_name, "")
  description = "Master username."
  sensitive   = true
}

output "opensearch_arn" {
  value       = try(module.opensearch.arn, "")
  description = "ARN of OpenSearch."
}

output "opensearch_domain_endpoint" {
  value       = try(module.opensearch.kibana_endpoint, "")
  description = "Domain-specific endpoint for kibana without https scheme."
}

output "opensearch_domain_id" {
  value       = try(module.opensearch.domain_id, "")
  description = "Domain ID of OpenSearch."
}

output "opensearch_domain_name" {
  value       = try(module.opensearch.domain_name, "")
  description = "Domain name of OpenSearch."
}

output "opensearch_endpoint" {
  value       = try(module.opensearch.endpoint, "")
  description = "Domain-specific endpoint used to submit index, search, and data upload requests."
}
# @section services.opensearch.enabled end
