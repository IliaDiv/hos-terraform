provider "aws" {
    region = "us-east-1"
    assume_role {
      role_arn     = "arn:aws:iam::337909746080:role/hos-terraform"
      session_name = "terraform"
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}



terraform {
 required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
 }
}

##############################################################################################
# Backend-tf.state
##############################################################################################

terraform {
  backend "s3" {
    bucket = "home-office-store-infrastracture"
    key    = "terraform/dev"
    region = "us-east-1"
    use_lockfile = true
  }
}