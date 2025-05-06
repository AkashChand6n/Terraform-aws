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

# Get latest Amazon Linux 2 AMI from SSM
data "aws_ssm_parameter" "latest_amazon_linux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# VPC
resource "aws_vpc" "UST-B-VPC" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = "UST-B-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "UST-B-IGW" {
  vpc_id = aws_vpc.UST-B-VPC.id
  tags = {
    Name = "UST-B-IGW"
  }
}

# Public Subnet
resource "aws_subnet" "UST-B-PubSub" {
  vpc_id            = aws_vpc.UST-B-VPC.id
  cidr_block        = var.cidr_block_subnet_public
  availability_zone = var.aws_region_az1
  tags = {
    Name = "UST-B-PubSub"
  }
}

# Private Subnet
resource "aws_subnet" "UST-B-PrivSub" {
  vpc_id            = aws_vpc.UST-B-VPC.id
  cidr_block        = var.cidr_block_subnet_private
  availability_zone = var.aws_region_az2
  tags = {
    Name = "UST-B-PrivSub"
  }
}

# Route Tables
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

resource "aws_route_table" "UST-B-PrivRT" {
  vpc_id = aws_vpc.UST-B-VPC.id
  route {
    cidr_block     = var.allow_all
    nat_gateway_id = aws_nat_gateway.UST-B-NATGW.id
  }
  tags = {
    Name = "UST-B-PrivRT"
  }
}

# Route Table Associations
resource "aws_route_table_association" "UST-B-PubRT-Assoc" {
  subnet_id      = aws_subnet.UST-B-PubSub.id
  route_table_id = aws_route_table.UST-B-PubRT.id
}

resource "aws_route_table_association" "UST-B-PrivRT-Assoc" {
  subnet_id      = aws_subnet.UST-B-PrivSub.id
  route_table_id = aws_route_table.UST-B-PrivRT.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "UST-B-ElasticIP" {
  domain = "vpc"
  tags = {
    Name = "UST-B-ElasticIP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "UST-B-NATGW" {
  allocation_id = aws_eip.UST-B-ElasticIP.id
  subnet_id     = aws_subnet.UST-B-PubSub.id
  tags = {
    Name = "UST-B-NATGW"
  }
}

# Security Group
resource "aws_security_group" "UST-B-SG" {
  name        = "UST-B-SG"
  description = "Security group for UST-B"
  vpc_id      = aws_vpc.UST-B-VPC.id

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

# Network ACL
resource "aws_network_acl" "UST-B-NACL" {
  vpc_id = aws_vpc.UST-B-VPC.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
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

resource "aws_network_acl_association" "UST-B-NACL-Assoc" {
  subnet_id      = aws_subnet.UST-B-PubSub.id
  network_acl_id = aws_network_acl.UST-B-NACL.id
}

resource "aws_network_acl_association" "UST-B-NACL-Assoc-Priv" {
  subnet_id      = aws_subnet.UST-B-PrivSub.id
  network_acl_id = aws_network_acl.UST-B-NACL.id
}

# EC2 Public Instance
resource "aws_instance" "UST-B-Pub-Instance" {
  ami                         = data.aws_ssm_parameter.latest_amazon_linux2.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.UST-B-PubSub.id
  vpc_security_group_ids      = [aws_security_group.UST-B-SG.id]
  associate_public_ip_address = true
  user_data                   = var.user_data
  tags = {
    Name = "UST-B-Pub-Instance"
  }
}

# EC2 Private Instance
resource "aws_instance" "UST-B-Priv-Instance" {
  ami                    = data.aws_ssm_parameter.latest_amazon_linux2.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.UST-B-PrivSub.id
  vpc_security_group_ids = [aws_security_group.UST-B-SG.id]
  user_data              = var.user_data
  tags = {
    Name = "UST-B-Priv-Instance"
  }
}

# Outputs
output "Public_Instance_ID" {
  value = aws_instance.UST-B-Pub-Instance.id
}

output "Private_Instance_ID" {
  value = aws_instance.UST-B-Priv-Instance.id
}

output "Public_IP" {
  value = aws_instance.UST-B-Pub-Instance.public_ip
}

output "Private_IP" {
  value = aws_instance.UST-B-Priv-Instance.private_ip
}
