plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Variables are declared for future use when K8s module is fully integrated
rule "terraform_unused_declarations" {
  enabled = false
}
