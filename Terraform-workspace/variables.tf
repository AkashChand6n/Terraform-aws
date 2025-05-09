variable "aws_region" {
    description = "AWS region to deploy the resources"
    type        = string
}

variable "instance_type" {
    description = "Type of the EC2 instance"
    type        = string
}

variable "instance_name" {
    description = "Name of the EC2 instance"
    type        = string
}