resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Environment = "dev"
    Name        = var.bucket_name
  }
}
