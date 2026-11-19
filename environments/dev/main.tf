data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Naming convention (spec section 12): <project>-<environment>-<resource>
  name_prefix = "${var.project_name}-${var.environment}"

  # Mandatory tags (spec section 12)
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # With 10.20.0.0/16 -> exactly the addressing plan of page 4:
  # public 10.20.1-2.0/24, app 10.20.11-12.0/24, db 10.20.21-22.0/24
  public_subnet_cidrs = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, 1 + i)]
  app_subnet_cidrs    = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, 11 + i)]
  db_subnet_cidrs     = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, 21 + i)]
}

module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  azs                 = local.azs
  public_subnet_cidrs = local.public_subnet_cidrs
  app_subnet_cidrs    = local.app_subnet_cidrs
  db_subnet_cidrs     = local.db_subnet_cidrs
  nat_mode            = var.nat_mode
}

module "storage" {
  source      = "../../modules/storage"
  name_prefix = local.name_prefix
}

module "security" {
  source      = "../../modules/security"
  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "database" {
  source = "../../modules/database"

  name_prefix         = local.name_prefix
  db_subnet_ids       = module.network.db_subnet_ids
  db_sg_id            = module.security.db_sg_id
  instance_class      = var.db_instance_class
  multi_az            = var.db_multi_az
  deletion_protection = var.db_deletion_protection
}

module "compute" {
  source = "../../modules/compute"

  name_prefix       = local.name_prefix
  project_name      = var.project_name
  environment       = var.environment
  app_subnet_ids    = module.network.app_subnet_ids
  app_sg_id         = module.security.app_sg_id
  target_group_arns = [module.load_balancer.target_group_arn]
  instance_type     = var.instance_type
  min_size          = var.min_size
  max_size          = var.max_size
  desired_capacity  = var.desired_capacity
  db_host           = module.database.db_address
  db_port           = module.database.db_port
  tags              = local.common_tags
}
