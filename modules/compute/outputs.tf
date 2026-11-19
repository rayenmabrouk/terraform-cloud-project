output "asg_name" {
  description = "Name of the Auto Scaling Group (used by the test scripts)."
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "ID of the launch template."
  value       = aws_launch_template.this.id
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI used."
  value       = data.aws_ssm_parameter.ami.insecure_value
}
