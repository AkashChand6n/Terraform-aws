provider "aws" {
  region = var.region
}

module "ec2_instance" {
  source        = "./modules/ec2"
  ami           = var.ami
  instance_type = var.instance_type
  name          = "target-ec2"
}

module "s3_bucket" {
  source = "./modules/s3_module"
  bucket_name = "my-khaleeda-ust-bucket"
}
