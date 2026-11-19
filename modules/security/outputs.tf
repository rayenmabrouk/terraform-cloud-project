output "alb_sg_id" {
  description = "Security group of the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security group of the application instances."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security group of the RDS instance."
  value       = aws_security_group.db.id
}
