variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "lbc_alb_sg" {
  type = list(string)
}