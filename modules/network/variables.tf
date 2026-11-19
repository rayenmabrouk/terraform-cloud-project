variable "name_prefix" {
  description = "Prefix for resource names: <project>-<environment>."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.name_prefix))
    error_message = "name_prefix: 3-24 chars, lowercase letters, digits, hyphens."
  }
}

variable "vpc_cidr" {
  description = "Main CIDR block of the VPC (e.g. 10.20.0.0/16)."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "azs" {
  description = "Availability zones (at least two)."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "nat_mode" {
  description = "Outbound access for private app subnets: none, single or per_az."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_mode)
    error_message = "nat_mode must be none, single or per_az."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnets (ALB, NAT), one per AZ, same order as azs."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "Private application subnets, one per AZ, same order as azs."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "Private database subnets, one per AZ, same order as azs."
  type        = list(string)
}

variable "tags" {
  description = "Extra tags merged into every resource."
  type        = map(string)
  default     = {}
}
