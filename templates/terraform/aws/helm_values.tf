# @param services.eks.helmCharts
variable "helm_charts" {
  description = "Helm chart selections from the frontend"
  type        = map(any)
  default     = {}
}

locals {
  # Get helm chart selections from services.eks.helmCharts
  # Expected structure: { prometheusStack: { enabled: true, customValues: false }, ... }
  helm_chart_selections = try(var.helm_charts, {})

  # Define all possible helm chart configurations
  # Values files are located in argocd/values/ directory
  # Note: Karpenter is managed in karpenter.tf directly
  all_helm_charts = {
    # @section promtail begin
    promtail = {
      enabled              = lookup(lookup(local.helm_chart_selections, "promtail", {}), "enabled", false)
      template_values_file = "${path.module}/../../argocd/values/promtail.yaml.tftpl"
      values = {
        logLevel = "info"
      }
    }
    # @section promtail end

    # @section aws_load_balancer_controller begin
    aws_load_balancer_controller = {
      enabled              = lookup(lookup(local.helm_chart_selections, "awsLoadBalancerController", {}), "enabled", false)
      template_values_file = "${path.module}/../../argocd/values/aws-lb-controller.yaml.tftpl"
      values = {
        service_account_name = local.aws_lb_service_account_name
        alb_role_arn         = module.alb_controller_irsa_role.arn
        cluster_name         = module.eks.cluster_name
        region               = var.region
        vpc_id               = module.vpc.vpc_id
        replica_count        = var.aws_lb_replica_count
        pdb_max_unavailable  = var.aws_lb_pdb_max_unavailable
      }
    }
    # @section aws_load_balancer_controller end

    # @section loki begin
    loki = {
      enabled              = lookup(lookup(local.helm_chart_selections, "loki", {}), "enabled", false)
      template_values_file = "${path.module}/../../argocd/values/loki.yaml.tftpl"
      values = {
        region               = var.region
        loki_role_arn        = module.loki_role.arn
        service_account_name = "loki-sa"
        s3_bucket_chunk      = module.loki_s3_buckets["chunk"].s3_bucket_id
        s3_bucket_ruler      = module.loki_s3_buckets["ruler"].s3_bucket_id
      }
    }
    # @section loki end
  }

  # Filter to only enabled helm charts
  helm_charts = {
    for chart_name, chart_config in local.all_helm_charts :
    chart_name => {
      template_values_file = chart_config.template_values_file
      values               = chart_config.values
    }
    if chart_config.enabled
  }
}

resource "local_file" "helm_chart_values" {
  for_each = local.helm_charts

  content = templatefile(
    each.value.template_values_file,
    each.value.values
  )
  filename = trimsuffix(each.value.template_values_file, ".tftpl")
}
