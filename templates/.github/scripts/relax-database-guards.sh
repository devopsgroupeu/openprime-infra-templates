set -eu

# Clears the database teardown guards before `terraform destroy`.
#
# destroy plans deletions only - it never updates an attribute first. So
# deletion_protection has to be cleared by an apply, or AWS refuses
# DeleteDBInstance and the failure cascades to the DB subnets, the internet
# gateway and finally the VPC. The same apply sets apply_immediately, so the
# change does not wait for the maintenance window, and records the final
# snapshot choice in the state, which is where destroy reads it from.
#
# The apply targets only the RDS instances and Aurora clusters that are in the
# state (Terraform adds what they depend on). An untargeted apply on a
# half-built environment first tries to build everything that is missing, and
# when that fails the destroy never runs (OP-265). With no database in the
# state there is nothing to relax and no apply runs at all.
#
# Usage: sh .github/scripts/relax-database-guards.sh <terraform root, e.g. terraform/aws>
# Env:   SKIP_FINAL_SNAPSHOT  "true" deletes the databases without a final snapshot
#        RUN_ID               names the Aurora final snapshot: aurora-final-<RUN_ID>

root="${1:?usage: relax-database-guards.sh <terraform root, e.g. terraform/aws>}"
cd "$root"

# Default to keeping the snapshot: an empty input must not read as "skip".
# Only true/false: Terraform would read "1" as true while this script would
# take it as "keep the snapshot".
skip="${SKIP_FINAL_SNAPSHOT:-false}"
case "$skip" in
  true | false) ;;
  *)
    printf 'ERROR: SKIP_FINAL_SNAPSHOT must be true or false, got: %s\n' "$skip" >&2
    exit 1
    ;;
esac

state="$(terraform state list)"
databases="$(printf '%s\n' "$state" |
  grep -E -e '^aws_(db_instance|rds_cluster)\.' -e '\.aws_(db_instance|rds_cluster)\.' |
  grep -Ev -e '^data\.' -e '\.data\.')" || true

if [ -z "$databases" ]; then
  printf '%s\n' 'No RDS instance or Aurora cluster in the state, so there is nothing to relax.'
  exit 0
fi

set --
while IFS= read -r address; do
  set -- "$@" "-target=$address"
done <<EOF
$databases
EOF
printf 'Relaxing the teardown guards of:\n%s\n' "$databases"

# The rds module derives its own snapshot name; the aurora module passes ours
# straight through and aws_rds_cluster rejects an empty one unless the
# snapshot is skipped.
snapshot_id=""
if [ "$skip" != "true" ]; then
  snapshot_id="aurora-final-${RUN_ID:?RUN_ID is required to name the Aurora final snapshot}"
fi

terraform apply -auto-approve "$@" \
  -var rds_deletion_protection=false \
  -var rds_apply_immediately=true \
  -var rds_skip_final_snapshot="$skip" \
  -var aurora_deletion_protection=false \
  -var aurora_apply_immediately=true \
  -var aurora_skip_final_snapshot="$skip" \
  -var aurora_final_snapshot_identifier="$snapshot_id"
