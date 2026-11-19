variable "name_prefix" {
  description = "Prefix for resource names (ALB/TG names are limited to 32 chars)."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB (at least two AZs)."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "An ALB requires subnets in at least two availability zones."
  }
}

variable "alb_sg_id" {
  description = "Security group attached to the ALB."
  type        = string
}

variable "target_port" {
  description = "Port the targets (web instances) listen on."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP path checked by the target group health check."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with /."
  }
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN. When set: HTTPS listener + HTTP->HTTPS redirect."
  type        = string
  default     = null
}

variable "tags" {
  description = "Extra tags merged into every resource."
  type        = map(string)
  default     = {}
}
