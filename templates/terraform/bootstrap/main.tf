data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # git@host:group/repo.git, ssh://git@host:port/group/repo.git, https://host/group/repo.git
  repo_url_pattern = "^(?:[A-Za-z+]+://)?(?:[^@/]+@)?([^/:]+)(?::[0-9]+)?[:/](.+?)(?:\\.git)?/?$"
  repo_url_parts   = regex(local.repo_url_pattern, var.git_repo_url)
  git_host         = lower(local.repo_url_parts[0])
  repo_path        = local.repo_url_parts[1]

  # Same rule as the OpenPrime wizard: self-hosted GitLab is recognised by
  # "gitlab" in its host name.
  is_gitlab   = strcontains(local.git_host, "gitlab")
  issuer_url  = local.is_gitlab ? coalesce(var.gitlab_url, "https://${local.git_host}") : "https://token.actions.githubusercontent.com"
  issuer_host = trimsuffix(trimprefix(local.issuer_url, "https://"), "/")
  audience    = "sts.amazonaws.com"

  # The "sub" claim GitHub and GitLab put into the job's token. Plan accepts
  # any branch and pull/merge requests of this repository; apply and destroy
  # only runs on the deploy branch, so a changed workflow on another branch
  # cannot get them.
  subject_any_ref = local.is_gitlab ? "project_path:${local.repo_path}:*" : "repo:${local.repo_path}:*"
  subject_deploy = (local.is_gitlab
    ? "project_path:${local.repo_path}:ref_type:branch:ref:${var.deploy_branch}"
    : "repo:${local.repo_path}:ref:refs/heads/${var.deploy_branch}"
  )

  roles = {
    plan    = { subject = local.subject_any_ref, test = "StringLike", policy = "ReadOnlyAccess", max_session = 3600 }
    apply   = { subject = local.subject_deploy, test = "StringEquals", policy = "AdministratorAccess", max_session = 14400 }
    destroy = { subject = local.subject_deploy, test = "StringEquals", policy = "AdministratorAccess", max_session = 14400 }
  }

  # Fixed per repository and branch, so every environment in the account gets
  # its own roles and a re-run finds the same names.
  name_prefix = "openprime-${substr(sha1("${local.repo_path}@${var.deploy_branch}"), 0, 10)}"

  oidc_provider_arn = (var.create_oidc_provider
    ? aws_iam_openid_connect_provider.ci[0].arn
    : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.issuer_host}"
  )
}

resource "aws_iam_openid_connect_provider" "ci" {
  count = var.create_oidc_provider ? 1 : 0

  url            = local.issuer_url
  client_id_list = [local.audience]
}

data "aws_iam_policy_document" "trust" {
  for_each = local.roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.issuer_host}:aud"
      values   = [local.audience]
    }

    condition {
      test     = each.value.test
      variable = "${local.issuer_host}:sub"
      values   = [each.value.subject]
    }
  }
}

resource "aws_iam_role" "pipeline" {
  for_each = local.roles

  name                 = "${local.name_prefix}-${each.key}"
  description          = "OpenPrime pipeline ${each.key} role for ${local.repo_path} (${var.deploy_branch})"
  assume_role_policy   = data.aws_iam_policy_document.trust[each.key].json
  max_session_duration = each.value.max_session
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  for_each = local.roles

  role       = aws_iam_role.pipeline[each.key].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/${each.value.policy}"
}

# Plan only reads, except for the lock file that S3 native locking writes next
# to each state while Terraform runs.
resource "aws_iam_role_policy" "plan_state_lock" {
  name = "terraform-state-lock"
  role = aws_iam_role.pipeline["plan"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:DeleteObject"]
      Resource = "arn:${data.aws_partition.current.partition}:s3:::${var.state_bucket}/*.tflock"
    }]
  })
}
