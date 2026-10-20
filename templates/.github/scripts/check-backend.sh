set -eu
for root in terraform/aws terraform/kubernetes; do
  (
    cd "$root"
    terraform init -input=false -reconfigure
    jq -e '
      .backend.type |
      (type == "string" and . != "" and . != "local" and . != "none")
    ' "${TF_DATA_DIR:-.terraform}/terraform.tfstate" >/dev/null || {
      echo "ERROR: The CI/CD pipeline cannot run for $root without a remote Terraform state backend. State stored locally on a CI runner can 
            be lost when the job ends, leaving Terraform unable to track the resources it created and making them difficult to manage safely. 
            Configure a remote backend in your OpenPrime environment settings, save the environment, and push the infrastructure again before rerunning the pipeline." >&2
      exit 1
    }
  )
done
