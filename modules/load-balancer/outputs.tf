output "alb_dns_name" {
  description = "Public DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "alb_url" {
  description = "URL of the application."
  value       = "${local.https_enabled ? "https" : "http"}://${aws_lb.this.dns_name}"
}

output "target_group_arn" {
  description = "Target group the Auto Scaling Group registers instances into."
  value       = aws_lb_target_group.app.arn
}
