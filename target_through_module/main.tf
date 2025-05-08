provider "aws" {
  region = var.region
}

module "ec2_instance" {
  source        = "./modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  name          = "target-ec2"
}

module "s3_bucket" {
  source = "./modules/s3_module"
  bucket_name = "my-khaleeda-ust-bucket"
}
