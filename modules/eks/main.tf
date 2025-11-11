##############################################################################################
# EKS
##############################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.eks_name
  kubernetes_version = var.kubernetes_version

    access_entries = {
    # One access entry with a policy associated
    localadmin = {
      principal_arn = "arn:aws:iam::337909746080:user/localadmin"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
  default = {
    min_size     = 1
    max_size     = 2
    desired_size = 1

    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types   = ["t3.large"] 

    iam_role_attach_cni_policy = true

    vpc_security_group_ids = [
        var.node_security_group_id
      ]
    
    timeouts = {
        create = "25m"
        update = "25m"
        delete = "25m"
      }
  }
}

  vpc_id     = var.vpc_id
  subnet_ids = var.eks_subnet_ids
  control_plane_subnet_ids = var.eks_subnet_ids

  tags = var.eks_tags
}


