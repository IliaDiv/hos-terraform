module "rds" {
  source = "../../modules/rds"
  engine_version = var.engine_version
  identifier = var.identifier
  allocated_storage = var.allocated_storage
  vpc_security_group_ids = [module.sg.rds_sg_id]
  postgres_tags = var.postgres_tags
  rds_subnet_ids = module.vpc.private_subnets
  family = var.family
  major_engine_version = var.major_engine_version

  depends_on = [ module.sg, module.vpc ]
}

module "eks" {
  source = "../../modules/eks"
  eks_name = var.eks_name
  kubernetes_version = var.kubernetes_version
  node_security_group_id = module.sg.eks_nodes_sg_id
  vpc_id = module.vpc.vpc_id
  eks_subnet_ids = module.vpc.private_subnets
  eks_tags = var.eks_tags

  depends_on = [ module.sg, module.vpc ]
}

module "vpc" {
  source = "../../modules/vpc"
  region = var.region
  vpc_name = var.vpc_name
  cidr     = var.cidr
  public_subnet_size  = var.public_subnet_size
  private_subnet_size = var.private_subnet_size
  vpc_tags = var.vpc_tags
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id

  depends_on = [ module.vpc ]
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  vpc_id = module.vpc.vpc_id
  cluster_name = module.eks.cluster_name
  rds_endpoint = module.rds.rds_endpoint
  lbc_alb_sg = [module.sg.alb_sg_id]

  depends_on = [ module.eks, module.vpc, module.sg ]
}