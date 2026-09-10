#!/usr/bin/env bash
set -euo pipefail

# Requires gh, jq, actions:read, issues:write, and repository metadata access.
# Only human users with current write/maintain/admin access may decide.
# Run after the selected plan job succeeds, with an outer timeout over 55 minutes.
# TF_STACK is aws (default) or kubernetes; PLAN_JOB_NAME must match that stack.
# The workflow must apply the same saved plan. This script never reads plan data.
for name in GH_TOKEN GH_REPO TF_ACTION GITHUB_SERVER_URL GITHUB_RUN_ID \
  GITHUB_RUN_ATTEMPT GITHUB_REF_NAME GITHUB_SHA GITHUB_ACTOR; do
  if [[ -z "${!name:-}" ]]; then
    printf 'Missing required environment variable: %s\n' "$name" >&2
    exit 1
  fi
done

case "$TF_ACTION" in
  apply) ;;
  destroy)
    printf 'Destroy approval requires separate staged destruction plans; a normal apply plan cannot authorize it.\n' >&2
    exit 1
    ;;
  *) printf 'TF_ACTION must be apply or destroy.\n' >&2; exit 1 ;;
esac

command -v gh >/dev/null
command -v jq >/dev/null

run_url="${GITHUB_SERVER_URL}/${GH_REPO}/actions/runs/${GITHUB_RUN_ID}/attempts/${GITHUB_RUN_ATTEMPT}"
stack=${TF_STACK:-aws}
case "$stack" in
  aws) stack_label=AWS; expected_plan_job="plan:aws" ;;
  kubernetes) stack_label=Kubernetes; expected_plan_job="plan:k8s" ;;
  *) printf 'TF_STACK must be aws or kubernetes.\n' >&2; exit 1 ;;
esac
plan_job_name=${PLAN_JOB_NAME:-$expected_plan_job}
if [[ "$plan_job_name" != "$expected_plan_job" ]]; then
  printf 'PLAN_JOB_NAME does not match TF_STACK.\n' >&2
  exit 1
fi

# Restrict discovery to this run attempt. Never fall back to another attempt or
# branch's latest run: a rerun that reuses older jobs needs a fresh full run.
if ! jobs=$(gh api --paginate \
  "repos/${GH_REPO}/actions/runs/${GITHUB_RUN_ID}/attempts/${GITHUB_RUN_ATTEMPT}/jobs?per_page=100"); then
  printf 'Cannot read plan job metadata. Grant the approval job actions: read. No approval issue was created.\n' >&2
  exit 1
fi

if ! plan_url=$(jq -ers \
  --arg name "$plan_job_name" --arg sha "$GITHUB_SHA" \
  --arg run "$GITHUB_RUN_ID" --arg attempt "$GITHUB_RUN_ATTEMPT" \
  --arg prefix "${GITHUB_SERVER_URL}/${GH_REPO}/actions/runs/${GITHUB_RUN_ID}/job/" '
    [.[].jobs[] | select(.name == $name)] |
    if length != 1 then error("Expected exactly one matching plan job")
    else .[0] |
      if .status != "completed" or .conclusion != "success" or
         .head_sha != $sha or (.run_id | tostring) != $run or
         (.run_attempt | tostring) != $attempt
      then error("Plan must succeed for this commit and run attempt")
      elif (.html_url | type) != "string" then error("Missing plan job URL")
      elif (.html_url | startswith($prefix) | not) then error("Unexpected plan job URL")
      else .html_url end
    end' <<< "$jobs"); then
  printf 'No matching successful plan to approve. Make the approval job depend on its plan job, check PLAN_JOB_NAME, and rerun all jobs if necessary.\n' >&2
  exit 1
fi

body="Review the Terraform Plan step in the linked successful ${stack_label} plan job before approving.

Operation: ${TF_ACTION}
Stack: ${stack_label}
Repository: ${GH_REPO}
Branch: ${GITHUB_REF_NAME}
Commit: ${GITHUB_SHA}
Requested by: @${GITHUB_ACTOR}
Workflow: ${run_url}
Plan job: ${plan_url}

Approval covers applying the saved ${stack_label} plan from this run attempt.
It does not authorize another stack or destruction.
Plan contents are intentionally not copied into this issue.

Comment approve, approved, lgtm, or yes to continue.
Comment reject, rejected, deny, denied, or no to cancel.
Only users with Write, Maintain, or Admin repository access can decide.
The requester may also approve. Closing this issue cancels the request.
This request expires after 55 minutes."

# Always create a fresh issue so previous runs cannot supply an approval.
issue_url=$(gh issue create --repo "$GH_REPO" \
  --title "Approve Terraform ${TF_ACTION} (${stack_label}) — run ${GITHUB_RUN_ID}, attempt ${GITHUB_RUN_ATTEMPT}" \
  --body "$body")

printf 'Approval issue: %s\n' "$issue_url"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf 'Review the [%s plan](%s), then comment on the [approval issue](%s).\n' \
    "$stack_label" "$plan_url" "$issue_url" >> "$GITHUB_STEP_SUMMARY"
fi

deadline=$((SECONDS + 3300))
issue_number=${issue_url##*/}
while (( SECONDS < deadline )); do
  # API failures stop the job rather than bypassing approval.
  state=$(gh issue view "$issue_url" --repo "$GH_REPO" --json state --jq '.state')
  if [[ "$state" != "OPEN" ]]; then
    printf 'Approval issue is not open: %s\n' "$issue_url" >&2
    exit 1
  fi

  # Paginate all comments. Only exact decision words (ignoring case, outer
  # whitespace and trailing punctuation) count; quoted prose is ignored.
  comments=$(gh api --paginate "repos/${GH_REPO}/issues/${issue_number}/comments?per_page=100" \
    --jq '.[] | select(.user.type == "User") |
      (.body | ascii_downcase | gsub("^\\s+|\\s+$"; "") | sub("[.!]+$"; "")) as $word |
      select($word | test("^(approve|approved|lgtm|yes|reject|rejected|deny|denied|no)$")) |
      [.user.login, $word] | @tsv')

  decision=pending
  approver=""
  while IFS=$'\t' read -r login word; do
    [[ -n "$login" ]] || continue
    permission=$(gh api "repos/${GH_REPO}/collaborators/${login}/permission" --jq '.permission')
    case "$permission" in
      write|maintain|admin) ;;
      *) continue ;;
    esac
    case "$word" in
      reject|rejected|deny|denied|no)
        decision=rejected
        approver=$login
        break
        ;;
      *) decision=approved; approver=$login ;;
    esac
  done <<< "$comments"

  case "$decision" in
    approved)
      gh issue close "$issue_url" --repo "$GH_REPO" \
        --comment "Approved by @${approver} for commit ${GITHUB_SHA}. Reviewed plan: ${plan_url}. Continuing ${run_url}."
      exit 0
      ;;
    rejected)
      gh issue close "$issue_url" --repo "$GH_REPO" \
        --comment "Rejected by @${approver}. Run: ${run_url}"
      printf 'Approval rejected: %s\n' "$issue_url" >&2
      exit 1
      ;;
    pending) sleep 15 ;;
    *) printf 'Unexpected approval state: %s\n' "$decision" >&2; exit 1 ;;
  esac
done

gh issue close "$issue_url" --repo "$GH_REPO" \
  --comment "Approval timed out after 55 minutes. Run: ${run_url}"
exit 1
