provider "aws" {
  region = var.aws_region
}

module "ec2_instance" {
  source  = "AkashChand6n/ec2-instance/aws"
  version = "1.0.0"
}
