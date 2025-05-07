locals {
  common_tags = {
    Environment = "dev"
    Project     = "UST-ClassB"
  }

  subnets = {
    public = {
      cidr = var.cidr_block_subnet_public
      az   = var.aws_region_az1
    }
    private = {
      cidr = var.cidr_block_subnet_private
      az   = var.aws_region_az2
    }
  }

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allow_all]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.allow_all]
    }
  ]
}
