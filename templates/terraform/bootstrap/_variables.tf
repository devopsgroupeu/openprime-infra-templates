variable "region" {
  type        = string
  description = "AWS region of this environment"
}

variable "git_repo_url" {
  type        = string
  description = "SSH or HTTPS URL of this repository on GitHub or GitLab"

  validation {
    condition     = can(regex(local.repo_url_pattern, var.git_repo_url))
    error_message = "git_repo_url must look like git@host:group/repo.git, ssh://git@host:port/group/repo.git or https://host/group/repo.git."
  }
}

variable "deploy_branch" {
  type        = string
  description = "The branch OpenPrime delivers to. Only runs on it may assume the apply and destroy roles."
}

variable "state_bucket" {
  type        = string
  description = "S3 bucket that holds this environment's Terraform state"
}

variable "create_oidc_provider" {
  type        = bool
  description = "An AWS account holds one OIDC provider per issuer. Set to false when an earlier environment in this account already created it."
  default     = true
}

variable "gitlab_url" {
  type        = string
  description = "GitLab only: the instance's HTTPS URL, when it differs from https://<host of git_repo_url>. AWS must be able to reach it."
  default     = ""
}
