output "db_address" {
  description = "Private DNS name of the database (resolves to a private IP only)."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Database port."
  value       = aws_db_instance.this.port
}

output "db_identifier" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.identifier
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN of the generated credentials."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
