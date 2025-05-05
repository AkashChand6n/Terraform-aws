provider "aws" {
  region = var.aws_region
}

module "ec2_instance" {
  source        = "git::https://github.com/AkashChand6n/terraform-aws-ec2-instance.git"
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  aws_region    = var.aws_region
}
