variable "ami" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0f88e80871fd81e91"  # Replace with your default AMI ID
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "ust.pem"  # Replace with your default key name
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
