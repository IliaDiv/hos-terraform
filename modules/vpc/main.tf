##############################################################################################
# VPC
##############################################################################################

locals {
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets = [
    for az in local.azs : cidrsubnet(var.cidr, var.public_subnet_size, 100 + index(local.azs, az))
  ]
  private_subnets = [
    for az in local.azs : cidrsubnet(var.cidr, var.private_subnet_size, (index(local.azs, az) + length(local.azs) + 1))
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.vpc_tags
}