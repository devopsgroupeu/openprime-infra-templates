terraform {
  required_version = "~> 1.11"

  # @section backend begin
  backend "s3" {
    # @param backend.s3.bucket
    bucket = "my-terraform-state-bucket"
    key    = "aws.tfstate"
    # @param backend.s3.region
    region = "eu-west-1"
    # @param backend.s3.encrypt
    encrypt = true
    # @param backend.s3.useLockFile
    use_lockfile = false
  }
  # @section backend end

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge({
      "Customer"  = "DevOpsGroup"
      "Terraform" = "true"
    }, var.global_tags)
  }
}
