# -------------------------------------------------------------------
# COMMON
# -------------------------------------------------------------------

variable "region" {
  type        = string
  description = "The AWS region, where networking infrastructure will be created (e.g. 'eu-west-1')"
  default     = "eu-west-1"
}

variable "global_prefix" {
  type        = string
  description = "Global prefix to be used in almost every resource name created by this code"
  default     = "u"
}

variable "environment" {
  description = "Name of the environment"
  type        = string
  default     = "development"
}


variable "environment_short" {
  description = "Short name of the environment (e.g., dev)"
  type        = string
  default     = "dev"
}


variable "global_tags" {
  type        = map(string)
  description = "Global tags to be used in almost every resource created by this code"
  default     = {}
}

# -------------------------------------------------------------------
# ARGOCD
# -------------------------------------------------------------------

variable "git_repo_url" {
  type        = string
  description = "SSH URL of the Git repository to be used by ArgoCD"
}

variable "git_target_revision" {
  type        = string
  description = "Target branch to sync from"
}
