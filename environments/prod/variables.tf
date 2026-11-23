variable "aws_region" {
  description = "AWS region (Learner Lab: us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project prefix used in every resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,11}$", var.project_name))
    error_message = "project_name: 3-12 chars, lowercase letters, digits, hyphens."
  }
}

variable "environment" {
  description = "Environment name."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be dev, test or prod."
  }
}

variable "owner" {
  description = "Owner tag."
  type        = string
}

variable "vpc_cidr" {
  description = "Main CIDR of the VPC; subnets are derived from it."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr must be a valid /16 IPv4 CIDR."
  }
}

variable "nat_mode" {
  description = "Outbound access for the app tier: none, single or per_az."
  type        = string
  default     = "single"
}

variable "instance_type" {
  description = "EC2 instance type of the web tier."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Initial number of instances."
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ."
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Protect the database against deletion."
  type        = bool
  default     = false
}
