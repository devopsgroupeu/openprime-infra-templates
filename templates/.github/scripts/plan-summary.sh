set -eu

# Writes plan-summary.json, the change counts GitLab's merge request widget
# reads from `reports: terraform`. It replaces publishing the full
# `terraform show -json` output, which contains every sensitive value in plain
# text.
#
# Usage: sh .github/scripts/plan-summary.sh <terraform root>   (reads <root>/tfplan)

root="${1:?usage: plan-summary.sh <terraform root>}"

if ! command -v jq >/dev/null 2>&1; then
  if command -v apk >/dev/null 2>&1; then
    apk add --no-cache jq >/dev/null
  else
    printf '%s\n' 'ERROR: jq is required to summarise the Terraform plan.' >&2
    exit 1
  fi
fi

cd "$root"
terraform show -json tfplan | jq -c '
  [.resource_changes[]?.change.actions] as $a
  | {
      create: [$a[] | select(index("create"))] | length,
      update: [$a[] | select(. == ["update"])] | length,
      delete: [$a[] | select(index("delete"))] | length
    }' > plan-summary.json
