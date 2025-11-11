# MAIN
env = "dev"
region = "us-east-1"

# VPC
public_subnet_size = 8
private_subnet_size = 8
vpc_name = "demo"
cidr = "10.0.0.0/16"
vpc_tags = {
  "madeby" = "tf",
  "tf" = "vpc",
  "env" = "dev"
}

# EKS
eks_name = "demo"
kubernetes_version = "1.33"
eks_tags = {
  "madeby" = "tf",
  "tf" = "eks",
  "env" = "dev"
}


# RDS-POSTGRES
identifier = "demodb"
engine_version = "17.6"
allocated_storage = 5
# vpc_security_group_ids = output.postgres_sg
postgres_tags = {
  "madeby" = "tf",
  "tf" = "postgres",
  "env" = "dev"
}
# rds_subnet_ids = output.private_subnets
family = "postgres17"
major_engine_version = "17"






