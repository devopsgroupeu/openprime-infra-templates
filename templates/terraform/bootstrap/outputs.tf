output "pipeline_variables" {
  description = "Set each as a repository variable, not a secret (GitHub: Settings → Secrets and variables → Actions → Variables; GitLab: Settings → CI/CD → Variables)."
  value = {
    AWS_PLAN_ROLE_ARN    = aws_iam_role.pipeline["plan"].arn
    AWS_APPLY_ROLE_ARN   = aws_iam_role.pipeline["apply"].arn
    AWS_DESTROY_ROLE_ARN = aws_iam_role.pipeline["destroy"].arn
  }
}
