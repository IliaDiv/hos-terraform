data "aws_secretsmanager_secret_version" "rds" {
  secret_id = var.db_secrets_name
}

locals {
  rds_secret = jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)
}
##############################################################################################
# RDS
##############################################################################################

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.identifier

  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = "db.m5.large"
  allocated_storage = var.allocated_storage

  db_name  = "postgres"
  username = local.rds_secret.username
  password = local.rds_secret.password
  port     = "5432"

  manage_master_user_password = false

  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true

  vpc_security_group_ids = var.vpc_security_group_ids

  tags = var.postgres_tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.rds_subnet_ids

  # DB parameter group
  family = var.family

  # DB option group
  major_engine_version = var.major_engine_version

  # Database Deletion Protection
  # deletion_protection = true
}