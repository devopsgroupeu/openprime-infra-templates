# @section services.msk.enabled begin
locals {
  msk_cluster_name = "${var.global_prefix}msk-${var.environment}"
}

module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "~> 3.3"

  name                   = local.msk_cluster_name
  kafka_version          = var.msk_kafka_version
  number_of_broker_nodes = var.msk_number_of_broker_nodes

  broker_node_client_subnets  = module.vpc.private_subnets
  broker_node_instance_type   = var.msk_broker_node_instance_type
  broker_node_security_groups = [module.security_group.id]

  tags = {
    Name = local.msk_cluster_name
  }
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name        = "${local.msk_cluster_name}-sg"
  description = "Security group for ${local.msk_cluster_name}"
  vpc_id      = module.vpc.vpc_id

  enable_exclusive_rules = false

  ingress_rules = merge(
    {
      for index, cidr in module.vpc.private_subnets_cidr_blocks :
      "kafka-plaintext-${index}" => {
        from_port   = 9092
        to_port     = 9092
        ip_protocol = "tcp"
        cidr_ipv4   = cidr
      }
    },
    {
      for index, cidr in module.vpc.private_subnets_cidr_blocks :
      "kafka-tls-${index}" => {
        from_port   = 9094
        to_port     = 9094
        ip_protocol = "tcp"
        cidr_ipv4   = cidr
      }
    }
  )

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}
# @section services.msk.enabled end
