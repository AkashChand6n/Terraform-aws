terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Create ec2 instance 1
resource "aws_instance" "terraform_ec2-1" {
  ami="ami-0e449927258d45bc4"
  instance_type = "t2.micro"
  tags = { 
        Name = "terraform_ec2-1"
    }
}

# Create ec2 instance 2
resource "aws_instance" "terraform_ec2-2" {
  ami="ami-0e449927258d45bc4"
  instance_type = "t2.micro"
  tags = { 
        Name = "terraform_ec2-2"
    }
}

# Create ec2 instance 3
resource "aws_instance" "terraform_ec2-3" {
  ami="ami-0e449927258d45bc4"
  instance_type = var.instance_type
  tags = { 
        Name = "terraform_ec2-3"
    }
}

#create s3 bucket 1
resource "aws_s3_bucket" "khaleedaust123-1" {
    bucket = "khaleedaust123-1"
    tags = {
        Name = "khaleedaust123-1"
        Environment = "dev"
    }
}

#create s3 bucket 2
resource "aws_s3_bucket" "khaleedaust123-2" {
    bucket = "khaleedaust123-2"
    tags = {
        Name = "khaleedaust123-2"
        Environment = "dev"
    }
}
#create s3 bucket 3
resource "aws_s3_bucket" "khaleedaust123-3" {
    bucket = "khaleedaust123-3"
    tags = {
        Name = "khaleedaust123-3"
        Environment = "dev"
    }
}