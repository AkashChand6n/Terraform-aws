variable "my_string" {
  type    = string
  default = "Hello from Terraform"
}

variable "my_number" {
  type    = number
  default = 5
}

variable "my_list" {
  type    = list(string)
  default = ["apple", "banana", "cherry"]
}

variable "my_set" {
  type    = set(string)
  default = ["docker", "kubernetes", "terraform"]
}

variable "my_map" {
  type = map(string)
  default = {
    dev  = "10.0.1.0/24"
    prod = "10.0.2.0/24"
  }
}
