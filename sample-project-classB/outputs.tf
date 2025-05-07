output "public_instance_id" {
  value = aws_instance.UST_B_Pub_Instance.id
}

output "private_instance_id" {
  value = aws_instance.UST_B_Priv_Instance.id
}

output "public_ip" {
  value = aws_instance.UST_B_Pub_Instance.public_ip
}

output "private_ip" {
  value = aws_instance.UST_B_Priv_Instance.private_ip
}
