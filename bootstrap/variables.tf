variable "aws_region" {
  description = "Region of the state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix used in resource names."
  type        = string
  default     = "cloud5"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,11}$", var.project_name))
    error_message = "project_name: 3-12 chars, lowercase letters, digits, hyphens."
  }
}

variable "owner" {
  description = "Owner tag."
  type        = string
}
