terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

variable "region" {
    description = "AWS region to deploy resources"
    type        = list(string)
    default     = ["us-east-1a","us-east-1b","us-east-1c"]
}

resource "aws_vpc" "custom_vpc" {
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "custom-vpc"
    }
}

resource "aws_subnet" "custom_vpc" {
    count = length(var.region)
    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = cidrsubnet("10.0.0.0/16", 4, count.index)
    availability_zone = var.region[count.index]
}