# @param gitRepository.url
git_repo_url = "git@github.com:devopsgroupeu/openprime-infra-templates.git"
# @param gitRepository.branch
git_target_revision = "main"
# @param domain
ingress_domain = ""

# -------------------------------------------------------------------
# ARGOCD
# -------------------------------------------------------------------

# @param services.eks.argocdHaEnabled | displayName=Argo CD High Availability | description=Run Argo CD with redundant replicas and Redis HA (needs at least 3 nodes) | type=toggle
argocd_ha_enabled = false
# @param services.eks.argocdOidcIssuer | displayName=Argo CD SSO Issuer URL | description=OIDC issuer for Argo CD single sign-on, e.g. a Keycloak realm URL. Empty keeps the local admin login | type=text
argocd_oidc_issuer = ""
# @param services.eks.argocdOidcClientId | displayName=Argo CD SSO Client ID | description=Public OIDC client (PKCE) registered for Argo CD | type=text
argocd_oidc_client_id = ""
# @param services.eks.argocdAdminGroups | valueType=list | displayName=Argo CD Admin Groups | description=SSO groups granted the Argo CD admin role. When set, the local admin login is disabled | type=array
argocd_admin_groups = []