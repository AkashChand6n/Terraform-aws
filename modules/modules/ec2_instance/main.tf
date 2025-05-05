resource "aws_instance" "My-test-ec2" {
  ami = var.ami
  instance_type = var.instance_type
}