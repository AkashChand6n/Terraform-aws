resource "aws_vpc" "UST_B_VPC" {
  cidr_block = var.cidr_block_vpc
  tags = merge(local.common_tags, { Name = "UST-B-VPC" })
}

resource "aws_internet_gateway" "UST_B_IGW" {
  vpc_id = aws_vpc.UST_B_VPC.id
  tags   = merge(local.common_tags, { Name = "UST-B-IGW" })
}

resource "aws_subnet" "UST_B_Subnet" {
  for_each = local.subnets

  vpc_id            = aws_vpc.UST_B_VPC.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge(local.common_tags, { Name = "UST-B-${each.key}-subnet" })
}

resource "aws_route_table" "UST_B_PubRT" {
  vpc_id = aws_vpc.UST_B_VPC.id
  route {
    cidr_block = var.allow_all
    gateway_id = aws_internet_gateway.UST_B_IGW.id
  }
  tags = merge(local.common_tags, { Name = "UST-B-PubRT" })
}

resource "aws_route_table" "UST_B_PrivRT" {
  vpc_id = aws_vpc.UST_B_VPC.id
  route {
    cidr_block     = var.allow_all
    nat_gateway_id = aws_nat_gateway.UST_B_NATGW.id
  }
  tags = merge(local.common_tags, { Name = "UST-B-PrivRT" })
}

resource "aws_route_table_association" "UST_B_PubRT_Assoc" {
  subnet_id      = aws_subnet.UST_B_Subnet["public"].id
  route_table_id = aws_route_table.UST_B_PubRT.id
}

resource "aws_route_table_association" "UST_B_PrivRT_Assoc" {
  subnet_id      = aws_subnet.UST_B_Subnet["private"].id
  route_table_id = aws_route_table.UST_B_PrivRT.id
}

resource "aws_eip" "UST_B_ElasticIP" {
  domain = "vpc"
  tags   = merge(local.common_tags, { Name = "UST-B-ElasticIP" })
}

resource "aws_nat_gateway" "UST_B_NATGW" {
  allocation_id = aws_eip.UST_B_ElasticIP.id
  subnet_id     = aws_subnet.UST_B_Subnet["public"].id
  tags          = merge(local.common_tags, { Name = "UST-B-NATGW" })
}

resource "aws_security_group" "UST_B_SG" {
  name        = "UST-B-SG"
  description = "Security group for UST-B"
  vpc_id      = aws_vpc.UST_B_VPC.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_all]
  }

  tags = merge(local.common_tags, { Name = "UST-B-SG" })
}

resource "aws_network_acl" "UST_B_NACL" {
  vpc_id = aws_vpc.UST_B_VPC.id

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

resource "aws_network_acl_association" "UST_B_NACL_Assoc_Pub" {
  subnet_id      = aws_subnet.UST_B_Subnet["public"].id
  network_acl_id = aws_network_acl.UST_B_NACL.id
}

resource "aws_network_acl_association" "UST_B_NACL_Assoc_Priv" {
  subnet_id      = aws_subnet.UST_B_Subnet["private"].id
  network_acl_id = aws_network_acl.UST_B_NACL.id
}

resource "aws_instance" "UST_B_Pub_Instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.UST_B_Subnet["public"].id
  vpc_security_group_ids      = [aws_security_group.UST_B_SG.id]
  associate_public_ip_address = true
  user_data                   = var.user_data
  tags                        = merge(local.common_tags, { Name = "UST-B-Pub-Instance" })
}

resource "aws_instance" "UST_B_Priv_Instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.UST_B_Subnet["private"].id
  vpc_security_group_ids = [aws_security_group.UST_B_SG.id]
  user_data              = var.user_data
  tags                   = merge(local.common_tags, { Name = "UST-B-Priv-Instance" })
}
