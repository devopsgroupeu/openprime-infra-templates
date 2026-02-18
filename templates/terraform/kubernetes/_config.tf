terraform {
  required_version = "~> 1.11"

  # @section backend begin
  backend "s3" {
    # @param terraformBackend.bucketName
    bucket = "my-terraform-state-bucket"
    key    = "kubernetes.tfstate"
    # @param region
    region = "eu-west-1"
    # @param terraformBackend.encrypt
    encrypt = true
    # @param terraformBackend.useLockfile
    use_lockfile = true
  }
  # @section backend end

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge({
      "customer"  = "DevOpsGroup"
      "terraform" = "true"
    }, var.global_tags)
  }
}

provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.aws.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aws.outputs.eks_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.aws.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aws.outputs.eks_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "kubectl" {
  host                   = data.terraform_remote_state.aws.outputs.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.aws.outputs.eks_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.aws.outputs.eks_cluster_name
}
