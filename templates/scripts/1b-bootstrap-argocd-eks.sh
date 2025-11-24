#!/usr/bin/env bash
set -euo pipefail
###############################################################################
# 1b-bootstrap-argocd-eks.sh
# ────────────────────────────────────────────────────────────────────────────
# Kubernetes *platform* bootstrap for EKS cluster:
#   • Argo CD install with admin password
#   • Git SSH repository secret (for Argo CD)
#   • AppProject + App-of-Apps Application
#
# Expects EKS cluster to be already provisioned and kubectl configured
###############################################################################

# ── inputs (env or prompt) ──────────────────────────────────────────────────
GIT_REPO_URL="${GIT_REPO_URL:-}"
SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY:-}"
ARGOCD_PASS="${ARGOCD_PASS:-}"

[[ -z "$GIT_REPO_URL" ]] && read -p "Enter Git repo SSH URL              : " GIT_REPO_URL
if [[ -z "$SSH_PRIVATE_KEY" ]]; then
  echo "Paste SSH private key, end with EOF (Ctrl-D):"
  SSH_PRIVATE_KEY="$(cat)"
fi
[[ -z "$ARGOCD_PASS" ]] && read -s -p "Enter desired Argo CD admin password : " ARGOCD_PASS && echo

# ── ensure kubectl can talk to the API ───────────────────────────────────────
if ! kubectl version >/dev/null 2>&1; then
  echo "ERROR: kubectl cannot connect to Kubernetes API." >&2
  echo "Please configure kubectl to connect to your EKS cluster:" >&2
  echo "  aws eks update-kubeconfig --name <cluster-name> --region <region>" >&2
  exit 1
fi

# ── htpasswd for bcrypt hashing ──────────────────────────────────────────────
if ! command -v htpasswd >/dev/null; then
  echo "Installing *htpasswd* utility…"
  if command -v apt-get >/dev/null; then
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apache2-utils
  elif command -v dnf >/dev/null; then
    dnf install -y -q httpd-tools
  elif command -v yum >/dev/null; then
    yum install -y -q httpd-tools
  elif command -v brew >/dev/null; then
    brew install httpd
  else
    echo "ERROR: cannot install 'htpasswd' automatically." >&2
    exit 1
  fi
fi

# ── Argo CD admin password hash (bcrypt $2a$…) ──────────────────────────────
ARGOCD_HASH="$(
  htpasswd -nbBC 10 "" "$ARGOCD_PASS" |
    tr -d ':\n' |
    sed 's/\$2y/\$2a/'
)"

# ── Git repo SSH secret for Argo CD ─────────────────────────────────────────
echo "Creating Git SSH secret in argocd…"
kubectl get ns argocd >/dev/null 2>&1 || kubectl create ns argocd
# convert literal '\n' → real newlines
printf -v KEY_STR '%b\n' "${SSH_PRIVATE_KEY//\\n/$'\n'}"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: git-ssh-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  name: git-ssh-creds
  project: default
  sshPrivateKey: |
$(echo "$KEY_STR" | sed 's/^/    /')
  type: git
  url: $GIT_REPO_URL
EOF

# ── Argo CD installation ────────────────────────────────────────────────────
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace --version 8.1.2 \
  --set configs.secret.createSecret=true \
  --set-string configs.secret.argocdServerAdminPassword="$ARGOCD_HASH"

echo -e "\n✔ Argo CD installed."

# ── Default AppProject + app-of-apps Application ────────────────────────────
echo "Bootstrapping app-of-apps…"
sleep 10
if ! kubectl get appproject default -n argocd >/dev/null 2>&1; then
  cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: default
  namespace: argocd
spec:
  description: default project
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - namespace: '*'
    server: '*'
  orphanedResources:
    warn: true
  sourceRepos:
  - '*'
EOF
fi

# TODO: after testing set the targetRevision correctly
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $GIT_REPO_URL
    path: templates/argocd/charts/internal/app-of-apps
    targetRevision: openprime-init-integration
    helm:
      valueFiles:
      - ../../../applications.yaml
  destination:
    name: in-cluster
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# ── Force Argo CD refresh & finish ──────────────────────────────────────────
echo
echo "⏳ Waiting 10s before forcing Argo CD refresh…"
sleep 10
kubectl -n argocd annotate application app-of-apps \
  argocd.argoproj.io/refresh=hard --overwrite || true

echo
echo "🎉  Platform bootstrap finished."
echo
