provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  version       = "5.8.0"
  ami           = var.ami
  instance_type = var.instance_type
}

output "ec2_instance_ids" {
  value = module.ec2.id
}
