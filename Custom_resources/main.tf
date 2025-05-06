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

# Create a VPC with a CIDR block 
resource "aws_vpc" "UST-A-VPC" {
    cidr_block = "192.168.0.0/24"
    tags = {
        Name = "UST-A-VPC"
      
    }
}

# Create a internet gateway
resource "aws_internet_gateway" "UST-A-IGW" {
  vpc_id = aws_vpc.UST-A-VPC.id
  tags = {
    Name = "UST-A-IGW"
  }
  
}

# Create a subnet
resource "aws_subnet" "UST-A-PubSub" {
    vpc_id = aws_vpc.UST-A-VPC.id
    cidr_block = "192.168.0.0/25"
    # map_customer_owned_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
        Name = "UST-A-PubSub"
    }
}

# Create a subnet
resource "aws_subnet" "UST-A-PrivSub" {
    vpc_id = aws_vpc.UST-A-VPC.id
    cidr_block = "192.168.0.128/25"
    availability_zone = "us-east-1b"
    tags = {
        Name = "UST-A-PrivSub"
    }
}

# Create a route table
resource "aws_route_table" "UST-A-PubRT" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.UST-A-IGW.id
  }
  tags = {
    Name = "UST-A-PubRT"
  }
}

# Create a route table
resource "aws_route_table" "UST-A-PrivRT" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.UST-A-NATGW.id
  }
  tags = {
    Name = "UST-A-PrivRT"
  }
}

# Create a route table association
resource "aws_route_table_association" "UST-A-PubRT-Assoc" {
  subnet_id      = aws_subnet.UST-A-PubSub.id
  route_table_id = aws_route_table.UST-A-PubRT.id
}

# Create a route table association
resource "aws_route_table_association" "UST-A-PrivRT-Assoc" {
  subnet_id = aws_subnet.UST-A-PrivSub.id
  route_table_id = aws_route_table.UST-A-PrivRT.id
}

# create a elastic ip
resource "aws_eip" "UST-A-ElasticIP" {
  domain = "vpc"
  tags = {
    Name = "UST-A-ElasticIP"
  }
}

# Create a NAT gateway
resource "aws_nat_gateway" "UST-A-NATGW" {
  allocation_id = aws_eip.UST-A-ElasticIP.id
  subnet_id     = aws_subnet.UST-A-PubSub.id
  tags = {
    Name = "UST-A-NATGW"
  }
}

# Create a security group
resource "aws_security_group" "UST-A-SG" {
    name       = "UST-A-SG"
    description = "Security group for UST-A"
    vpc_id = aws_vpc.UST-A-VPC.id
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "UST-A-SG"
    }
}

# Create a NACL
resource "aws_network_acl" "UST-A-NACL" {
    vpc_id = aws_vpc.UST-A-VPC.id
    ingress {
        rule_no    = 100
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        }
    egress {
        rule_no    = 100
        protocol   = "-1"
        from_port  = 0
        to_port    = 0
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        }  
}

# Create a NACL association
resource "aws_network_acl_association" "UST-A-NACL-Assoc" {
    subnet_id = aws_subnet.UST-A-PubSub.id
    network_acl_id = aws_network_acl.UST-A-NACL.id  
}

# Create a NACL association
resource "aws_network_acl_association" "UST-A-NACL-Assoc-Priv" {
    subnet_id = aws_subnet.UST-A-PrivSub.id
    network_acl_id = aws_network_acl.UST-A-NACL.id  
}

# Ec2 Public instance
resource "aws_instance" "UST-A-Pub-Instance" {
    ami = "ami-0f88e80871fd81e91"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.UST-A-PubSub.id
    vpc_security_group_ids = [aws_security_group.UST-A-SG.id]
    associate_public_ip_address = true
    tags = {
        Name = "UST-A-Pub-Instance"
    }
    user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Hello from UST-A-Pub-Instance</h1>" > /var/www/html/index.html
    EOF
  
}

resource "aws_instance" "UST-A-Priv-Instance" {
    ami = "ami-0f88e80871fd81e91"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.UST-A-PrivSub.id
    vpc_security_group_ids = [aws_security_group.UST-A-SG.id]
    # associate_public_ip_address = false
    tags = {
        Name = "UST-A-Priv-Instance"
    }
    user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      echo "<h1>Hello from UST-A-Priv-Instance</h1>" > /var/www/html/index.html
    EOF
  
}

# Outputs for the created resources
output "Instance_ID" {
  value = aws_instance.UST-A-Pub-Instance.id
}
output "Instance_ID_Priv" {
  value = aws_instance.UST-A-Priv-Instance.id
}

output "Public_IP" {
  value = aws_instance.UST-A-Pub-Instance.public_ip
}
output "private_IP" {
  value = aws_instance.UST-A-Priv-Instance.private_ip
}