variable "name_prefix" {
  description = "Prefix for resource names: <project>-<environment>."
  type        = string
}

variable "log_retention_days" {
  description = "Days before objects under logs/ are deleted."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 3650
    error_message = "log_retention_days must be between 1 and 3650."
  }
}

variable "noncurrent_version_days" {
  description = "Days before old (non-current) object versions are deleted."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_days >= 1
    error_message = "noncurrent_version_days must be at least 1."
  }
}

variable "tags" {
  description = "Extra tags (propagated by CloudFormation to the bucket)."
  type        = map(string)
  default     = {}
}
