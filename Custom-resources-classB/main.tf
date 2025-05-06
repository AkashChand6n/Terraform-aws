terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region  
}

# Create a VPC with a CIDR block 
resource "aws_vpc" "UST-B-VPC" {
    cidr_block = var.cidr_block_vpc
    tags = {
        Name = "UST-B-VPC"
      
    }
}

# Create a internet gateway
resource "aws_internet_gateway" "UST-B-IGW" {
  vpc_id = aws_vpc.UST-B-VPC.id
  tags = {
    Name = "UST-B-IGW"
  }
  
}

# Create a subnet
resource "aws_subnet" "UST-B-PubSub" {
    vpc_id = aws_vpc.UST-B-VPC.id
    cidr_block = var.cidr_block_subnet_public
    # map_customer_owned_ip_on_launch = true
    availability_zone = var.aws_region_az1
    tags = {
        Name = "UST-B-PubSub"
    }
}

# Create a subnet
resource "aws_subnet" "UST-B-PrivSub" {
    vpc_id = aws_vpc.UST-B-VPC.id
    cidr_block = var.cidr_block_subnet_private
    availability_zone = var.aws_region_az2
    tags = {
        Name = "UST-B-PrivSub"
    }
}

# Create a route table
resource "aws_route_table" "UST-B-PubRT" {
  vpc_id = aws_vpc.UST-B-VPC.id
  route {
    cidr_block = var.allow_all
    gateway_id = aws_internet_gateway.UST-B-IGW.id
  }
  tags = {
    Name = "UST-B-PubRT"
  }
}

# Create a route table
resource "aws_route_table" "UST-B-PrivRT" {
  vpc_id = aws_vpc.UST-B-VPC.id
  route {
    cidr_block = var.allow_all
    nat_gateway_id = aws_nat_gateway.UST-A-NATGW.id
  }
  tags = {
    Name = "UST-B-PrivRT"
  }
}

# Create a route table association
resource "aws_route_table_association" "UST-B-PubRT-Assoc" {
  subnet_id      = aws_subnet.UST-B-PubSub.id
  route_table_id = aws_route_table.UST-B-PubRT.id
}

# Create a route table association
resource "aws_route_table_association" "UST-B-PrivRT-Assoc" {
  subnet_id = aws_subnet.UST-B-PrivSub.id
  route_table_id = aws_route_table.UST-B-PrivRT.id
}

# create a elastic ip
resource "aws_eip" "UST-B-ElasticIP" {
  domain = "vpc"
  tags = {
    Name = "UST-B-ElasticIP"
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "UST-A-NATGW" {
  allocation_id = aws_eip.UST-B-ElasticIP.id
  subnet_id     = aws_subnet.UST-B-PubSub.id
  tags = {
    Name = "UST-A-NATGW"
  }
}

# Create a security group
resource "aws_security_group" "UST-B-SG" {
    name       = "UST-B-SG"
    description = "Security group for UST-B"
    vpc_id = aws_vpc.UST-B-VPC.id
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.allow_all]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [var.allow_all]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [var.allow_all]
    }
    tags = {
        Name = "UST-B-SG"
    }
}

# Create a NACL
resource "aws_network_acl" "UST-B-NACL" {
    vpc_id = aws_vpc.UST-B-VPC.id
    ingress {
        rule_no    = 100
        protocol   = "-1"
        from_port  = 22
        to_port    = 22
        action     = "allow"
        cidr_block = var.allow_all
        }
    egress {
        rule_no    = 100
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        action     = "allow"
        cidr_block = var.allow_all
        }  
}

# Create a NACL association
resource "aws_network_acl_association" "UST-B-NACL-Assoc" {
    subnet_id = aws_subnet.UST-B-PubSub.id
    network_acl_id = aws_network_acl.UST-B-NACL.id  
}

# Create a NACL association
resource "aws_network_acl_association" "UST-B-NACL-Assoc-Priv" {
    subnet_id = aws_subnet.UST-B-PrivSub.id
    network_acl_id = aws_network_acl.UST-B-NACL.id  
}

# Ec2 Public instance
resource "aws_instance" "UST-B-Pub-Instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.UST-B-PubSub.id
    vpc_security_group_ids = [aws_security_group.UST-B-SG.id]
    associate_public_ip_address = true
    tags = {
        Name = "UST-B-Pub-Instance"
    }
    user_data = var.user_data
}

resource "aws_instance" "UST-B-Priv-Instance" {
    ami = "ami-0f88e80871fd81e91"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.UST-B-PrivSub.id
    vpc_security_group_ids = [aws_security_group.UST-B-SG.id]
    # associate_public_ip_address = false
    tags = {
        Name = "UST-B-Priv-Instance"
    }
    user_data = var.user_data
}

# Outputs for the created resources
output "Instance_ID" {
  value = aws_instance.UST-B-Pub-Instance.id
}
output "Instance_ID_Priv" {
  value = aws_instance.UST-B-Priv-Instance.id
}

output "Public_IP" {
  value = aws_instance.UST-B-Pub-Instance.public_ip
}
output "private_IP" {
  value = aws_instance.UST-B-Priv-Instance.private_ip
}