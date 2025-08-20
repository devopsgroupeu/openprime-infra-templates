# @section backend begin
data "terraform_remote_state" "aws" {
  backend = "s3"
  
  config = {
    # @param backend.s3.bucket
    bucket         = "my-terraform-state-bucket"
    key            = "aws.tfstate"
    # @param backend.s3.dynamodb_table
    dynamodb_table = "terraform-state-lock"
    # @param backend.s3.region
    region         = "eu-west-1"
    # @param backend.s3.encrypt
    encrypt        = true
    # @param backend.s3.use_lockfile
    use_lockfile   = false
  }
}
# @section backend end