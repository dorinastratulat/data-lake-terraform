output "name" {
  description = "Name (id) of the RDS instance"
  value       = aws_db_instance.mssql.identifier
}

output "arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.mssql.arn
}

output "endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.mssql.endpoint
}

output "port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.mssql.port
}

output "pass_arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.mssql_pass.arn
}
