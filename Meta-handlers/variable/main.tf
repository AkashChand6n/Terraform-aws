variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}

terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
  region = var.region 
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "custom_vpc"
  }
}