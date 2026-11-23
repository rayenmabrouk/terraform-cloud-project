output "alb_url" {
  description = "Public URL of the application."
  value       = module.load_balancer.alb_url
}

output "asg_name" {
  description = "Auto Scaling Group name (test scripts)."
  value       = module.compute.asg_name
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "rds_address" {
  description = "Private DNS name of the database."
  value       = module.database.db_address
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN of the generated DB credentials."
  value       = module.database.master_user_secret_arn
}

output "assets_bucket" {
  description = "Project S3 bucket."
  value       = module.storage.bucket_name
}
