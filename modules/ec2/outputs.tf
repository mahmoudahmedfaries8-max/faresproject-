output "private_key_pem" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "public_instances" {
  value = aws_instance.public_proxy[*].id
}

output "private_instances" {
  value = aws_instance.private_backend[*].id
}
output "private_sg_id" {
  value = aws_security_group.private_sg.id
}
