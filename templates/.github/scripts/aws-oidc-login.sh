# Sourced by GitLab jobs (". .github/scripts/aws-oidc-login.sh"), not run.
#
# Points the AWS SDK in Terraform and the aws CLI at this job's GitLab ID token
# (id_tokens: AWS_ID_TOKEN) and at the role named in AWS_ROLE_VARIABLE. They
# trade the token for short-lived credentials themselves; no AWS access keys
# are stored anywhere. The roles come from terraform/bootstrap.

case "${AWS_ROLE_VARIABLE:-}" in
  AWS_PLAN_ROLE_ARN | AWS_APPLY_ROLE_ARN | AWS_DESTROY_ROLE_ARN) ;;
  *)
    printf '%s\n' "ERROR: AWS_ROLE_VARIABLE must name one of the pipeline role variables, not '${AWS_ROLE_VARIABLE:-}'." >&2
    exit 1
    ;;
esac

# The name was checked above, so this reads exactly that variable.
eval "AWS_ROLE_ARN=\${$AWS_ROLE_VARIABLE:-}"
if [ -z "$AWS_ROLE_ARN" ]; then
  printf '%s\n' "ERROR: CI/CD variable $AWS_ROLE_VARIABLE is not set. The pipeline signs in to AWS with roles, not access keys: run terraform/bootstrap once and set the variables it prints (README: Connecting the pipeline to AWS)." >&2
  exit 1
fi

if [ -z "${AWS_ID_TOKEN:-}" ]; then
  printf '%s\n' "ERROR: This job has no AWS_ID_TOKEN. It must extend .aws_id_token in .gitlab-ci.yml." >&2
  exit 1
fi

# Left-over access keys would take precedence over the role in the AWS SDK.
if [ -n "${AWS_ACCESS_KEY_ID:-}${AWS_SECRET_ACCESS_KEY:-}${AWS_SESSION_TOKEN:-}" ]; then
  printf '%s\n' "WARNING: AWS access key variables are still set in the CI/CD settings. They are ignored now; delete them." >&2
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
fi

AWS_WEB_IDENTITY_TOKEN_FILE="$(mktemp)"
printf '%s' "$AWS_ID_TOKEN" >"$AWS_WEB_IDENTITY_TOKEN_FILE"
AWS_ROLE_SESSION_NAME="gitlab-${CI_PROJECT_ID:-0}-${CI_JOB_ID:-0}"
export AWS_ROLE_ARN AWS_WEB_IDENTITY_TOKEN_FILE AWS_ROLE_SESSION_NAME
