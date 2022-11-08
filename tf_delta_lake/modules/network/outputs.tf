output "security_group" {
  value = aws_security_group.allow_all
}

output "subnet_ids" {
  value = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}
