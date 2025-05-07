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