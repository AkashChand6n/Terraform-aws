terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Use provider null for test resources
provider "null" {}

# Local variables derived from input variables
locals {
  greeting     = var.my_string
  instance_num = var.my_number
  fruits       = var.my_list
  tools        = var.my_set
  cidr_blocks  = var.my_map
}

# Outputs to show locals
output "string_local" {
  value = local.greeting
}

output "number_local" {
  value = local.instance_num
}

output "list_local" {
  value = local.fruits
}

output "set_local" {
  value = local.tools
}

output "map_local" {
  value = local.cidr_blocks
}

# Use for_each with list (converted to set)
resource "null_resource" "fruit" {
  for_each = toset(local.fruits)

  provisioner "local-exec" {
    command = "echo Fruit: ${each.key}"
  }
}

# Use count to create repeated resources
resource "null_resource" "repeat_instance" {
  count = local.instance_num

  provisioner "local-exec" {
    command = "echo Instance number ${count.index + 1}"
  }
}

# Use for_each with a map (to show keys and values)
resource "null_resource" "env_cidr" {
  for_each = local.cidr_blocks

  provisioner "local-exec" {
    command = "echo Environment: ${each.key}, CIDR: ${each.value}"
  }
}
