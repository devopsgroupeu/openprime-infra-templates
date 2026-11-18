# One-time setup, run once by a person with administrator rights in the AWS
# account, not by the pipeline. It lets the pipeline sign in to AWS with a
# short-lived token from GitHub or GitLab instead of stored access keys.
#
# State stays local (terraform.tfstate in this folder; .gitignore keeps it out
# of git). Its bucket may hold other environments' state, and a shared
# bootstrap key would let one environment's bootstrap take over another's
# roles. Lost state is not dangerous: the role names are fixed, so a second
# apply stops with "EntityAlreadyExists" instead of creating duplicates.
terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "OpenPrime"               = "true"
      "Terraform"               = "true"
      "aws-apn-id-381790627163" = "pc:4lhqeluzjfvpd9gxqab2fs3y0"
    }
  }
}
