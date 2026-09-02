# @param gitRepository.url
git_repo_url = "git@github.com:devopsgroupeu/openprime-infra-templates.git"
# @param gitRepository.branch
git_target_revision = "main"
# @param services.eks.ingressDomain | displayName=Ingress Domain | description=Domain the cluster publishes ingresses on, e.g. example.com. Leave empty to ship no host-based ingresses. | type=text
ingress_domain = ""
