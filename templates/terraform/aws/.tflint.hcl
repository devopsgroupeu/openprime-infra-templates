plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.46.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Variables are declared via @param directives for template processing.
# Many are only referenced inside @section conditional blocks, so they
# appear "unused" after Injecto processes the template with disabled services.
rule "terraform_unused_declarations" {
  enabled = false
}
