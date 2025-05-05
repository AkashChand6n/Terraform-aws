output "instance_id" {
  value = aws_instance.My-test-ec2.id
}

output "Public_IP" {
  value = aws_instance.My-test-ec2.public_ip
}
