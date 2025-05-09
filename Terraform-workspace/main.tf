#terraform init
#terraform workspace new dev
#terraform workspace new prod
#terraform workspace select dev
#terraform workspace select prod
#terraform workspace list
#terraform workspace show
#terraform plan -var-file=dev.tfvars if you want to create a dev workspace
#terraform plan -var-file=prod.tfvars if you want to create a prod workspace
#terraform apply

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 instance for dev workspace only
resource "aws_instance" "demo_instance_dev" {
  count         = terraform.workspace == "dev" ? 1 : 0
  ami           = data.aws_ssm_parameter.amazon_linux2.value
  instance_type = var.instance_type
  tags = {
    Name = "${var.instance_name}-${terraform.workspace}"
  }
}

# EC2 instance for prod workspace only
resource "aws_instance" "demo_instance_prod" {
  count         = terraform.workspace == "prod" ? 1 : 0
  ami           = data.aws_ssm_parameter.amazon_linux2.value
  instance_type = var.instance_type
  tags = {
    Name = "${var.instance_name}-${terraform.workspace}"
  }
}

# Outputs for dev instance
output "instance_id_dev" {
  value       = terraform.workspace == "dev" ? aws_instance.demo_instance_dev[0].id : null
  description = "EC2 instance ID (only in dev workspace)"
}

output "instance_type_dev" {
  value       = terraform.workspace == "dev" ? aws_instance.demo_instance_dev[0].instance_type : null
  description = "EC2 instance type (only in dev workspace)"
}

# Outputs for prod instance
output "instance_id_prod" {
  value       = terraform.workspace == "prod" ? aws_instance.demo_instance_prod[0].id : null
  description = "EC2 instance ID (only in prod workspace)"
}

output "instance_type_prod" {
  value       = terraform.workspace == "prod" ? aws_instance.demo_instance_prod[0].instance_type : null
  description = "EC2 instance type (only in prod workspace)"
}
