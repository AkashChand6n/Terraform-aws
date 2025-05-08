variable "region" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0e449927258d45bc4"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "subnet_id" {
  description = "Provide a valid subnet ID in your default VPC"
}
