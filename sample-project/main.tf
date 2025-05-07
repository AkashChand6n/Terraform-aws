resource "aws_vpc" "UST-A-VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "UST-A-VPC"
  }
}

resource "aws_internet_gateway" "UST-A-IGW" {
  vpc_id = aws_vpc.UST-A-VPC.id
  tags = {
    Name = "UST-A-IGW"
  }
}

resource "aws_subnet" "UST-A-PubSub" {
  vpc_id            = aws_vpc.UST-A-VPC.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = local.availability_zones.public
  tags = {
    Name = "UST-A-PubSub"
  }
}

resource "aws_subnet" "UST-A-PrivSub" {
  vpc_id            = aws_vpc.UST-A-VPC.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = local.availability_zones.private
  tags = {
    Name = "UST-A-PrivSub"
  }
}

resource "aws_route_table" "UST-A-PubRT" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block = local.cidr_all
    gateway_id = aws_internet_gateway.UST-A-IGW.id
  }
  tags = {
    Name = "UST-A-PubRT"
  }
}

resource "aws_eip" "UST-A-ElasticIP" {
  domain = "vpc"
  tags = {
    Name = "UST-A-ElasticIP"
  }
}

resource "aws_nat_gateway" "UST-A-NATGW" {
  allocation_id = aws_eip.UST-A-ElasticIP.id
  subnet_id     = aws_subnet.UST-A-PubSub.id
  tags = {
    Name = "UST-A-NATGW"
  }
}

resource "aws_route_table" "UST-A-PrivRT" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block     = local.cidr_all
    nat_gateway_id = aws_nat_gateway.UST-A-NATGW.id
  }
  tags = {
    Name = "UST-A-PrivRT"
  }
}

resource "aws_route_table_association" "UST-A-PubRT-Assoc" {
  subnet_id      = aws_subnet.UST-A-PubSub.id
  route_table_id = aws_route_table.UST-A-PubRT.id
}

resource "aws_route_table_association" "UST-A-PrivRT-Assoc" {
  subnet_id      = aws_subnet.UST-A-PrivSub.id
  route_table_id = aws_route_table.UST-A-PrivRT.id
}

resource "aws_security_group" "UST-A-SG" {
  name        = "UST-A-SG"
  description = "Security group for UST-A"
  vpc_id      = aws_vpc.UST-A-VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.cidr_all]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.cidr_all]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.cidr_all]
  }

  tags = {
    Name = "UST-A-SG"
  }
}

resource "aws_network_acl" "UST-A-NACL" {
  vpc_id = aws_vpc.UST-A-VPC.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = local.cidr_all
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = local.cidr_all
  }
}

resource "aws_network_acl_association" "UST-A-NACL-Assoc" {
  subnet_id      = aws_subnet.UST-A-PubSub.id
  network_acl_id = aws_network_acl.UST-A-NACL.id
}

resource "aws_network_acl_association" "UST-A-NACL-Assoc-Priv" {
  subnet_id      = aws_subnet.UST-A-PrivSub.id
  network_acl_id = aws_network_acl.UST-A-NACL.id
}

resource "aws_instance" "UST-A-Pub-Instance" {
  ami                         = var.ami_id
  instance_type              = var.instance_type
  subnet_id                  = aws_subnet.UST-A-PubSub.id
  vpc_security_group_ids     = [aws_security_group.UST-A-SG.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from UST-A-Pub-Instance</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = local.instance_tags.pub
  }
}

resource "aws_instance" "UST-A-Priv-Instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.UST-A-PrivSub.id
  vpc_security_group_ids = [aws_security_group.UST-A-SG.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from UST-A-Priv-Instance</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = local.instance_tags.priv
  }
}