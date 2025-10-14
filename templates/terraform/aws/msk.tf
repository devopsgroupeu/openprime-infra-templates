# @section msk.enabled begin
locals {
  msk_cluster_name = "${var.global_prefix}msk-${var.environment_short}"
}

module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "~> 2.13"

  name = local.msk_cluster_name
  # @param msk.kafka_version
  kafka_version = "3.5.1"
  # @param msk.number_of_broker_nodes
  number_of_broker_nodes = 2

  broker_node_client_subnets = module.vpc.private_subnets
  # @param msk.broker_node_instance_type
  broker_node_instance_type   = "kafka.t3.small"
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
# @section msk.enabled end
