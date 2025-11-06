# @section services.msk.enabled begin
locals {
  msk_cluster_name = "${var.global_prefix}msk-${var.environment_short}"
}

module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "~> 2.13"

  name = local.msk_cluster_name
  kafka_version = var.msk_kafka_version
  number_of_broker_nodes = var.msk_number_of_broker_nodes

  broker_node_client_subnets = module.vpc.private_subnets
  broker_node_instance_type   = var.msk_broker_node_instance_type
  broker_node_security_groups = [module.security_group.security_group_id]

  tags = {
    Name = local.msk_cluster_name
  }
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${local.msk_cluster_name}-sg"
  description = "Security group for ${local.msk_cluster_name}"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  ingress_rules = [
    "kafka-broker-tcp",
    "kafka-broker-tls-tcp"
  ]
}
# @section services.msk.enabled end
