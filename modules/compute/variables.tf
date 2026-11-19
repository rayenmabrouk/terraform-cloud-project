variable "name_prefix" {
  description = "Prefix for resource names: <project>-<environment>."
  type        = string
}

variable "project_name" {
  description = "Project name shown on the demo page."
  type        = string
}

variable "environment" {
  description = "Environment name shown on the demo page."
  type        = string
}

variable "app_subnet_ids" {
  description = "Private app subnets the Auto Scaling Group spreads across."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_ids) >= 2
    error_message = "At least two app subnets (two AZs) are required."
  }
}

variable "app_sg_id" {
  description = "Security group of the instances."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile (Learner Lab: the pre-existing LabInstanceProfile)."
  type        = string
  default     = "LabInstanceProfile"
}

variable "target_group_arns" {
  description = "ALB target groups the instances register into."
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances (2 = survives the loss of one)."
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 2
    error_message = "min_size must be at least 2 for high availability."
  }
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= var.min_size
    error_message = "max_size must be >= min_size."
  }
}

variable "desired_capacity" {
  description = "Initial number of instances."
  type        = number
  default     = 2
}

variable "cpu_target" {
  description = "Average CPU (%) the target tracking policy maintains."
  type        = number
  default     = 50
}

variable "db_host" {
  description = "Database hostname tested by the demo page (empty = skip)."
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Database port tested by the demo page."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Tags for instances and volumes."
  type        = map(string)
  default     = {}
}
