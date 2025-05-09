terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

variable "instance_name" {
    description = "name of the instance"
    type        = string
    default     = "demo-instance"
}

data "aws_ssm_parameter" "latest_amazon_linux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

variable "create_instance" {
    description = "tring out the bool values"
    type = bool
    default = false
}

#will create an instance if the variable is set to true
#will not create an instance if the variable is set to false
resource "aws_instance" "demo-instance" {
    count = var.create_instance ? 1 : 0 #true : false
    ami = data.aws_ssm_parameter.latest_amazon_linux2.value #latest amazon linux 2 ami fetching it from the aws ssm parameter store
    instance_type = "t2.micro"
    tags = {
        Name = var.instance_name
    }
}

#crete a variable for the environment
variable "Env" {
    description = "environment name"
    type        = string
    default     = "dev"  
}

resource "aws_instance" "demo-env" {
    ami = data.aws_ssm_parameter.latest_amazon_linux2.value #latest amazon linux 2 ami fetching it from the aws ssm parameter store
    instance_type = var.Env=="dev" ? "t2.micro" : "t2.small"
    tags = {
        Name = var.instance_name
        Env  = var.Env
    }  
}

resource "aws_instance" "demo-env-2" {
    ami = data.aws_ssm_parameter.latest_amazon_linux2.value
    instance_type = var.Env=="prod" ? "t2.large" : "t2.small"
    tags = {
        Name = var.instance_name
        Env  = var.Env
        Name = terraform.workspace
    }
}

locals {
  instance_type = var.Env == "dev" ? "t3.micro" : var.Env == "prod" ? "t3.large" : "t3.small"
}
resource "aws_instance" "demo-env-3" {
    ami = data.aws_ssm_parameter.latest_amazon_linux2.value
    instance_type = local.instance_type
    tags = {
        Name = var.instance_name
        Env  = var.Env
    }
}
