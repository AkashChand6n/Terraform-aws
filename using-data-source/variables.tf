variable "aws_region" {
  description = "AWS region to deploy the resources"
  type        = string
}

variable "aws_region_az1" {
  description = "Availability zone for the first subnet"
  type        = string
}

variable "aws_region_az2" {
  description = "Availability zone for the second subnet"
  type        = string
}

variable "cidr_block_vpc" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "cidr_block_subnet_public" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "cidr_block_subnet_private" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "allow_all" {
  description = "CIDR block to allow all traffic"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "user_data" {
  description = "User data script for the EC2 instance"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
              EOF
}
