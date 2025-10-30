terraform {
  backend "s3" {
    bucket = "laxmireddy-terra"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    encrypt = true
  }
}