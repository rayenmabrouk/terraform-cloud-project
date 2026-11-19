output "state_bucket" {
  description = "Remote state bucket name (used by every environment backend)."
  value       = data.aws_s3_bucket.state.id
}
