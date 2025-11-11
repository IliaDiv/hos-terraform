variable "eks_name" {
    description = "the name for EKS cluster"
    type = string
}

variable "kubernetes_version" {
    description = "the kubernetes version"
    type = string
}

variable "node_security_group_id" {
    description = "string of sg id"
    type = string
}

variable "vpc_id" {
    type = string
}

variable "eks_subnet_ids" {
    description = "list of subnet ids for EKS"
    type = list(string)
}

variable "eks_tags" {
    description = "the tags for the EKS cluster"
    type = map(string)
}