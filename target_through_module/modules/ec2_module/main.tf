provider "aws" {
  region = var.aws_region
}
resource "aws_instance" "terraform_ec2-1" {
  ami=var.ami_id
  instance_type = var.instance_type
  tags = { 
        Name = "terraform_ec2-1"
    }
}