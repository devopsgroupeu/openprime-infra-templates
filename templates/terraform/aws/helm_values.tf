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
  all_helm_charts = {
    # @section karpenter begin
    karpenter = {
      enabled              = lookup(lookup(local.helm_chart_selections, "karpenter", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/karpenter/values.yaml.tftpl"
      values = {
        cluster_name     = module.eks.cluster_name
        cluster_endpoint = module.eks.cluster_endpoint
        queue_name       = module.karpenter.queue_name
      }
    }
    # @section karpenter end

    # @section promtail begin
    promtail = {
      enabled              = lookup(lookup(local.helm_chart_selections, "promtail", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/promtail/values.yaml.tftpl"
      values = {
        logLevel = "info"
      }
    }
    # @section promtail end

    # @section aws_load_balancer_controller begin
    aws_load_balancer_controller = {
      enabled              = lookup(lookup(local.helm_chart_selections, "awsLoadBalancerController", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/aws-load-balancer-controller/values.yaml.tftpl"
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
      template_values_file = "${path.module}/../../helm/loki/values.yaml.tftpl"
      values = {
        region               = var.region
        loki_role_arn        = module.loki_role.arn
        service_account_name = "loki-sa"
        s3_bucket_chunk      = module.loki_s3_buckets["chunk"].s3_bucket_id
        s3_bucket_ruler      = module.loki_s3_buckets["ruler"].s3_bucket_id
      }
    }
    # @section loki end

    # @section prometheus_stack begin
    prometheus_stack = {
      enabled              = lookup(lookup(local.helm_chart_selections, "prometheusStack", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/prometheus-stack/values.yaml.tftpl"
      values = {
        cluster_name = module.eks.cluster_name
        region       = var.region
      }
    }
    # @section prometheus_stack end

    # @section ingress_nginx begin
    ingress_nginx = {
      enabled              = lookup(lookup(local.helm_chart_selections, "ingressNginx", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/ingress-nginx/values.yaml.tftpl"
      values = {
        cluster_name = module.eks.cluster_name
        region       = var.region
      }
    }
    # @section ingress_nginx end

    # @section cert_manager begin
    cert_manager = {
      enabled              = lookup(lookup(local.helm_chart_selections, "certManager", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/cert-manager/values.yaml.tftpl"
      values = {
        cluster_name = module.eks.cluster_name
        region       = var.region
      }
    }
    # @section cert_manager end

    # @section tempo begin
    tempo = {
      enabled              = lookup(lookup(local.helm_chart_selections, "tempo", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/tempo/values.yaml.tftpl"
      values = {
        cluster_name = module.eks.cluster_name
        region       = var.region
      }
    }
    # @section tempo end

    # @section thanos begin
    thanos = {
      enabled              = lookup(lookup(local.helm_chart_selections, "thanos", {}), "enabled", false)
      template_values_file = "${path.module}/../../helm/thanos/values.yaml.tftpl"
      values = {
        cluster_name = module.eks.cluster_name
        region       = var.region
      }
    }
    # @section thanos end
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
