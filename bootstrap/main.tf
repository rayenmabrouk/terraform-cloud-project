data "aws_caller_identity" "current" {}

locals {
  # Account ID suffix = globally unique bucket name
  state_bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"
}

# Bucket created once (Learner Lab SCP blocks the provider's read of aws_s3_bucket).
# Terraform manages its hardening below; it never deletes the bucket itself.
data "aws_s3_bucket" "state" {
  bucket = local.state_bucket
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = data.aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled" # every state write is kept, rollback possible
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = data.aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = data.aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = data.aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced" # ACLs disabled
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = data.aws_s3_bucket.state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  depends_on = [aws_s3_bucket_versioning.state]
}
