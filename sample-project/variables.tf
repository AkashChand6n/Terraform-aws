variable "vpc_cidr" {
  default = "192.168.0.0/24"
}

variable "public_subnet_cidr" {
  default = "192.168.0.0/25"
}

variable "private_subnet_cidr" {
  default = "192.168.0.128/25"
}

variable "ami_id" {
  default = "ami-0f88e80871fd81e91"
}

variable "instance_type" {
  default = "t2.micro"
}