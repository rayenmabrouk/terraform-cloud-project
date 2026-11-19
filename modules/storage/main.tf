data "aws_caller_identity" "current" {}

locals {
  # Account ID suffix = globally unique bucket name
  bucket_name = "${var.name_prefix}-assets-${data.aws_caller_identity.current.account_id}"
}

# Learner Lab: an SCP blocks the provider's read of aws_s3_bucket
# (s3:GetBucketObjectLockConfiguration). The bucket is declared in a
# CloudFormation stack orchestrated by Terraform: still IaC, no blocked read.
resource "aws_cloudformation_stack" "bucket" {
  name = "${var.name_prefix}-storage"
  tags = var.tags

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09"
    Description              = "Project bucket of ${var.name_prefix} (managed by Terraform)"

    Resources = {
      Bucket = {
        Type           = "AWS::S3::Bucket"
        DeletionPolicy = "Delete"
        Properties = {
          BucketName              = local.bucket_name
          VersioningConfiguration = { Status = "Enabled" }
          BucketEncryption = {
            ServerSideEncryptionConfiguration = [
              { ServerSideEncryptionByDefault = { SSEAlgorithm = "AES256" } }
            ]
          }
          PublicAccessBlockConfiguration = {
            BlockPublicAcls       = true
            BlockPublicPolicy     = true
            IgnorePublicAcls      = true
            RestrictPublicBuckets = true
          }

          OwnershipControls = { Rules = [{ ObjectOwnership = "BucketOwnerEnforced" }] }
          LifecycleConfiguration = {
            Rules = [
              {
                Id               = "expire-logs"
                Status           = "Enabled"
                Prefix           = "logs/"
                ExpirationInDays = var.log_retention_days
              },
              {
                Id                             = "cleanup-old-versions"
                Status                         = "Enabled"
                NoncurrentVersionExpiration    = { NoncurrentDays = var.noncurrent_version_days }
                AbortIncompleteMultipartUpload = { DaysAfterInitiation = 7 }
              }
            ]
          }
        }
      }

      BucketPolicy = {
        Type = "AWS::S3::BucketPolicy"
        Properties = {
          Bucket = { Ref = "Bucket" }
          PolicyDocument = {
            Version = "2012-10-17"
            Statement = [{
              Sid       = "DenyInsecureTransport"
              Effect    = "Deny"
              Principal = "*"
              Action    = "s3:*"
              Resource = [
                { "Fn::GetAtt" = ["Bucket", "Arn"] },
                { "Fn::Sub" = "$${Bucket.Arn}/*" }
              ]
              Condition = { Bool = { "aws:SecureTransport" = "false" } }
            }]
          }
        }
      }
    }

    Outputs = {
      BucketName = { Value = { Ref = "Bucket" } }
      BucketArn  = { Value = { "Fn::GetAtt" = ["Bucket", "Arn"] } }
    }
  })
}
