# The DB can only live in the private, isolated DB subnets (no Internet route)
resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-db-subnets"
  description = "Private database subnets of ${var.name_prefix}"
  subnet_ids  = var.db_subnet_ids
  tags        = merge(var.tags, { Name = "${var.name_prefix}-db-subnets" })
}

resource "aws_db_parameter_group" "this" {
  name        = "${var.name_prefix}-pg${var.engine_version}"
  family      = "postgres${var.engine_version}"
  description = "PostgreSQL parameters of ${var.name_prefix}"

  # Encryption in transit: unencrypted client connections are rejected
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # Audit trail of every connection attempt
  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name_prefix}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true # encryption at rest (KMS)

  db_name  = var.db_name
  username = var.master_username
  # RDS generates the password and stores it in Secrets Manager:
  # it never exists in Git, in tfvars, or in the Terraform state.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = false # no public IP, ever
  multi_az               = var.multi_az

  backup_retention_period    = var.backup_retention_period
  auto_minor_version_upgrade = true
  apply_immediately          = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = !var.deletion_protection # dev/test: fast destroy; prod: final snapshot
  final_snapshot_identifier = var.deletion_protection ? "${var.name_prefix}-db-final" : null

  tags = merge(var.tags, { Name = "${var.name_prefix}-db" })
}
