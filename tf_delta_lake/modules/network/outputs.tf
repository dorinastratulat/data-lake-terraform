output "security_group" {
  value = aws_security_group.allow_all
}

output "subnet_ids" {
  value = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}
