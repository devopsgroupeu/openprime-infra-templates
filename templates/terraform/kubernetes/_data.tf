# @section backend begin
data "terraform_remote_state" "aws" {
  backend = "s3"

  config = {
    # @param terraformBackend.bucketName
    bucket = "my-terraform-state-bucket"
    key    = "aws.tfstate"
    # @param region
    region = "eu-west-1"
    # @param terraformBackend.encrypt
    encrypt = true
    # @param terraformBackend.useLockfile
    use_lockfile = true
  }
}
# @section backend end
