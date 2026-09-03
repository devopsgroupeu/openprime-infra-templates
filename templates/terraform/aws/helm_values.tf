locals {
  # Host-based ingresses are only emitted when the customer told us their domain.
  # Empty means no ingress at all, rather than publishing openprime.io - a domain
  # they do not own, whose ingresses resolve for nobody and whose ALB never finds
  # a certificate (OP-244).
  ingress_domain_set = var.ingress_domain != ""

  monitoring_ingress_hosts = {
    for name in ["alertmanager", "grafana", "prometheus"] :
    name => local.ingress_domain_set ? jsonencode(["${name}.${var.ingress_domain}"]) : "[]"
  }

  # NOT "[]". Measured on the chart rather than assumed: an empty domainFilters
  # drops --domain-filter from the container args entirely, and external-dns with
  # no domain filter considers EVERY hosted zone in the account. That is the
  # opposite of inert, and OP-243 means it now authenticates successfully. The
  # reserved .invalid TLD (RFC 2606) can never be a real public zone, so it is a
  # filter that matches nothing rather than a filter that matches everything.
  external_dns_domain_filters = local.ingress_domain_set ? jsonencode([var.ingress_domain]) : jsonencode(["none.invalid"])

  # Get helm chart selections from services.eks.helmCharts
  # Expected structure: { prometheusStack: { enabled: true, customValues: false }, ... }
  helm_chart_selections = try(var.helm_charts, {})

  # Define all possible helm chart configurations
  # Values files are located in argocd/values/ directory
  # Note: Karpenter is managed in karpenter.tf directly
  all_helm_charts = {
    # @section services.eks.helmCharts.prometheusStack.enabled begin
    prometheus_stack = {
      enabled              = try(local.helm_chart_selections["prometheusStack"]["enabled"], false)
      template_values_file = "${path.module}/../../argocd/values/kube-prometheus-stack.yaml.tftpl"
      values = {
        ingress_enabled    = local.ingress_domain_set
        alertmanager_hosts = local.monitoring_ingress_hosts["alertmanager"]
        grafana_hosts      = local.monitoring_ingress_hosts["grafana"]
        prometheus_hosts   = local.monitoring_ingress_hosts["prometheus"]
      }
    }
    # @section services.eks.helmCharts.prometheusStack.enabled end

    # @section services.eks.helmCharts.promtail.enabled begin
    promtail = {
      enabled              = try(local.helm_chart_selections["promtail"]["enabled"], false)
      template_values_file = "${path.module}/../../argocd/values/promtail.yaml.tftpl"
      values = {
        logLevel = "info"
      }
    }
    # @section services.eks.helmCharts.promtail.enabled end

    # @section services.eks.helmCharts.awsLoadBalancerController.enabled begin
    aws_load_balancer_controller = {
      enabled              = try(local.helm_chart_selections["awsLoadBalancerController"]["enabled"], false)
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
    # @section services.eks.helmCharts.awsLoadBalancerController.enabled end

    # @section services.eks.helmCharts.loki.enabled begin
    loki = {
      enabled              = try(local.helm_chart_selections["loki"]["enabled"], false)
      template_values_file = "${path.module}/../../argocd/values/loki.yaml.tftpl"
      values = {
        region               = var.region
        loki_role_arn        = module.loki_role.arn
        service_account_name = "loki-sa"
        s3_bucket_chunk      = module.loki_s3_buckets["chunk"].s3_bucket_id
        s3_bucket_ruler      = module.loki_s3_buckets["ruler"].s3_bucket_id
      }
    }
    # @section services.eks.helmCharts.loki.enabled end

    # @section services.eks.helmCharts.certManager.enabled begin
    cert_manager = {
      enabled              = try(local.helm_chart_selections["certManager"]["enabled"], false)
      template_values_file = "${path.module}/../../argocd/values/cert-manager.yaml.tftpl"
      values = {
        install_custom_resource_definitions = true
        replica_count                       = 1
        node_selector                       = "kubernetes.io/os: linux"
        metrics                             = true
        webhook_replica_count               = 1
        webhook_node_selector               = "kubernetes.io/os: linux"
        cainjector_replica_count            = 1
        cainjector_node_selector            = "kubernetes.io/os: linux"
      }
    }
    # @section services.eks.helmCharts.certManager.enabled end

    # @section services.eks.helmCharts.ingressNginx.enabled begin
    ingress_nginx = {
      enabled              = try(local.helm_chart_selections["ingressNginx"]["enabled"], false)
      template_values_file = "${path.module}/../../argocd/values/ingress-nginx.yaml.tftpl"
      values = {
        cpu_request                       = "100m"
        memory_request                    = "128Mi"
        metrics_enabled                   = true
        autoscaling_enabled               = true
        autoscaling_min_replicas          = 1
        autoscaling_max_replicas          = 5
        autoscaling_target_cpu_percentage = 80
        lb_backend_protocol               = "http"
        lb_connection_idle_timeout        = "3600"
        lb_type                           = "external"
        lb_nlb_target_type                = "ip"
        lb_scheme                         = "internet-facing"
      }
    }
    # @section services.eks.helmCharts.ingressNginx.enabled end

    # @section services.eks.helmCharts.externalDns.enabled begin
    external_dns = {
      enabled              = try(local.helm_chart_selections["externalDns"]["enabled"], false)
      template_values_file = "${path.module}/../../argocd/values/external-dns.yaml.tftpl"
      values = {
        service_account_name  = "external-dns-sa"
        external_dns_role_arn = module.external_dns_irsa_role.arn
        region                = var.region
        domain_filters        = local.external_dns_domain_filters
      }
    }
    # @section services.eks.helmCharts.externalDns.enabled end
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
