output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (for the ALB), in AZ order."
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "app_subnet_ids" {
  description = "Private app subnet IDs (for the Auto Scaling Group), in AZ order."
  value       = [for az in var.azs : aws_subnet.app[az].id]
}

output "db_subnet_ids" {
  description = "Private DB subnet IDs (for the RDS subnet group), in AZ order."
  value       = [for az in var.azs : aws_subnet.db[az].id]
}
