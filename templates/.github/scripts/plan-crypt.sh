set -eu

# Encrypts the saved Terraform plan before it leaves the plan job, and decrypts
# it in the apply job.
#
# A saved plan stores every input variable (the Argo CD deploy key among them)
# and the prior state (generated database passwords) in plain text; `sensitive`
# only hides values in printed output. Artifacts can be downloaded by anyone who
# can read the repository, so only this encrypted copy is uploaded.
#
# The key is derived from AWS_SECRET_ACCESS_KEY and the run, so no extra secret
# is needed: whoever can decrypt the plan can already read everything in it.
#
# Usage: sh .github/scripts/plan-crypt.sh encrypt|decrypt <terraform root>
# Env:   AWS_SECRET_ACCESS_KEY  the job's AWS credentials
#        PLAN_KEY_CONTEXT       the same run identifier in both jobs
#                               (GitHub: run id, GitLab: pipeline id)

mode="${1:?usage: plan-crypt.sh encrypt|decrypt <terraform root>}"
root="${2:?usage: plan-crypt.sh encrypt|decrypt <terraform root>}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY is required to encrypt or decrypt the plan}"
: "${PLAN_KEY_CONTEXT:?PLAN_KEY_CONTEXT is required to encrypt or decrypt the plan}"

if ! command -v openssl >/dev/null 2>&1; then
  if command -v apk >/dev/null 2>&1; then
    apk add --no-cache openssl >/dev/null
  else
    printf '%s\n' 'ERROR: openssl is required to encrypt the Terraform plan.' >&2
    exit 1
  fi
fi

TF_PLAN_KEY="$(printf 'openprime-tfplan:%s:%s' "$PLAN_KEY_CONTEXT" "$AWS_SECRET_ACCESS_KEY" | sha256sum | cut -d' ' -f1)"
export TF_PLAN_KEY

cd "$root"
case "$mode" in
  encrypt)
    openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt -pass env:TF_PLAN_KEY -in tfplan -out tfplan.enc
    rm -f tfplan
    ;;
  decrypt)
    openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -pass env:TF_PLAN_KEY -in tfplan.enc -out tfplan || {
      printf '%s\n' 'ERROR: Could not decrypt the saved plan. It must come from the plan job of this same run, with the same AWS credentials. Run the whole workflow again.' >&2
      rm -f tfplan
      exit 1
    }
    rm -f tfplan.enc
    ;;
  *)
    printf '%s\n' 'usage: plan-crypt.sh encrypt|decrypt <terraform root>' >&2
    exit 1
    ;;
esac
