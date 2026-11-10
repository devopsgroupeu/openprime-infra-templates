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

variable "git_repo_ssh_key" {
  type        = string
  description = "Private key of a read-only deploy key on the Git repository. Argo CD pulls the repository with it; use a different key from the one OpenPrime pushes with."
  sensitive   = true
}

variable "ingress_domain" {
  type        = string
  description = "Domain the cluster publishes ingresses on. Empty means no host-based ingress is created (OP-244)."
  default     = ""
}
