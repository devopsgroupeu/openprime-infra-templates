set -eu
for root in terraform/aws terraform/kubernetes; do
  (
    cd "$root"
    terraform init -input=false -reconfigure
    jq -e '
      .backend.type |
      (type == "string" and . != "" and . != "local" and . != "none")
    ' "${TF_DATA_DIR:-.terraform}/terraform.tfstate" >/dev/null || {
      echo "ERROR: $root requires a configured remote backend" >&2
      exit 1
    }
  )
done