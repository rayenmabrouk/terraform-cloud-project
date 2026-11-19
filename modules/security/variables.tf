variable "name_prefix" {
  description = "Prefix for resource names: <project>-<environment>."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC hosting the security groups."
  type        = string
}

variable "app_port" {
  description = "Port the application instances listen on."
  type        = number
  default     = 80

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "app_port must be a valid TCP port."
  }
}

variable "db_port" {
  description = "Database port (5432 = PostgreSQL)."
  type        = number
  default     = 5432

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "db_port must be a valid TCP port."
  }
}

variable "enable_https" {
  description = "Open 443 on the ALB (only when a TLS certificate is attached)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags merged into every resource."
  type        = map(string)
  default     = {}
}
