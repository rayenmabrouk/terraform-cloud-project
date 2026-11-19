output "bucket_name" {
  description = "Name of the project bucket."
  value       = aws_cloudformation_stack.bucket.outputs["BucketName"]
}

output "bucket_arn" {
  description = "ARN of the project bucket."
  value       = aws_cloudformation_stack.bucket.outputs["BucketArn"]
}
