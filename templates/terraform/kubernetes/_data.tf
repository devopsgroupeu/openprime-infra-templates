# @section backend begin
data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    # @param backend.s3.bucket
    bucket = "my-terraform-state-bucket"
    key    = "aws.tfstate"
    # @param backend.s3.region
    region = "eu-west-1"
    # @param backend.s3.encrypt
    encrypt = true
    # @param backend.s3.useLockfile
    use_lockfile = true
  }
}
# @section backend end
