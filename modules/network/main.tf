data "aws_region" "current" {}

locals {
  # AZ name -> index (stable for_each keys): {"us-east-1a" = 0, "us-east-1b" = 1}
  az_index = { for i, az in var.azs : az => i }

  # Short suffix for names: us-east-1a -> a
  az_suffix = { for az in var.azs : az => substr(az, length(az) - 1, 1) }

  # Which AZs get a NAT gateway
  nat_azs = (
    var.nat_mode == "per_az" ? var.azs :
    var.nat_mode == "single" ? [var.azs[0]] : []
  )
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # needed for RDS endpoint names

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

# --- Subnets: 3 tiers x 2 AZs = the 6 subnets of the spec (page 4) ---
resource "aws_subnet" "public" {
  for_each = local.az_index

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = var.public_subnet_cidrs[each.value]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${local.az_suffix[each.key]}"
    Tier = "public"
  })
}

resource "aws_subnet" "app" {
  for_each = local.az_index

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = var.app_subnet_cidrs[each.value]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-${local.az_suffix[each.key]}"
    Tier = "app"
  })
}

resource "aws_subnet" "db" {
  for_each = local.az_index

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = var.db_subnet_cidrs[each.value]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-${local.az_suffix[each.key]}"
    Tier = "db"
  })
}

# --- Public routing: public subnets -> Internet Gateway ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rt-public" })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# --- Controlled egress: NAT gateway(s) in the public subnets ---
resource "aws_eip" "nat" {
  for_each = toset(local.nat_azs)

  domain     = "vpc"
  tags       = merge(var.tags, { Name = "${var.name_prefix}-eip-nat-${local.az_suffix[each.key]}" })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_azs)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat-${local.az_suffix[each.key]}" })
  depends_on    = [aws_internet_gateway.this]
}

# --- App tier: one route table per AZ, default route via NAT ---
resource "aws_route_table" "app" {
  for_each = local.az_index

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.nat_mode == "none" ? [] : [1]
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[var.nat_mode == "per_az" ? each.key : var.azs[0]].id
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rt-app-${local.az_suffix[each.key]}" })
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app[each.key].id
}

# --- DB tier: isolated, NO route to the Internet ---
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-db" })
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}

# --- Free S3 gateway endpoint: S3 traffic never goes through the NAT ---
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.app : rt.id]

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-s3" })
}
