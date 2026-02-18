terraform {
  required_version = "~> 1.11"

  # @section backend begin
  backend "s3" {
    # @param terraformBackend.bucketName
    bucket = "my-terraform-state-bucket"
    key    = "aws.tfstate"
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
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge({
      "OpenPrime" = "true"
      "Terraform" = "true"
    }, var.global_tags)
  }
}
