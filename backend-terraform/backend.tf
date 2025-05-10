terraform {
  backend "s3" {
    bucket         = "demo-backend-workspace"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
  }
}
