# MAIN

variable "env" {
  description = "the working environment (dev/staging/prod)"
  type        = string
}

variable "region" {
  description = "the AWS region"
  type        = string
}

variable "aws_account_id" {
  type = string
}
# VPC

variable "public_subnet_size" {
  description = "the number of bits to add to CIDR and make a PUBLIC subnet"
  type        = number
}

variable "private_subnet_size" {
  description = "the number of bits to add to CIDR and make a PRIVATE subnet"
  type        = number
}

variable "vpc_name" {
  description = "the name of the VPC"
  type        = string
}

variable "cidr" {
  description = "the CIDR range of the VPC"
  type        = string
}

variable "vpc_tags" {
  description = "the tags of the VPC"
  type        = map(string)
}


# EKS

variable "eks_name" {
  description = "the name for EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "the kubernetes version"
  type        = string
}

variable "eks_tags" {
  description = "the tags for the EKS cluster"
  type        = map(string)
}

# RDS-POSTGRES

variable "identifier" {
  description = "the RDS POSTGRES engine version to use"
  type        = string
}

variable "engine_version" {
  description = "the RDS POSTGRES engine version to use"
  type        = string
}

variable "allocated_storage" {
  description = "how many GB storage RDS POSTGRES gets"
  type        = number
}

variable "postgres_tags" {
  description = "tags of the POSTGRES instance"
  type        = map(string)
}

variable "family" {
  description = "POSTGRES family"
  type        = string
}

variable "major_engine_version" {
  description = "the RDS POSTGRES MAJOR engine version to use"
  type        = string
}

# SECRETS

variable "openai_secrets_name" {
  description = "AWS Secrets Manager name for n8n secrets"
  type        = string
}

variable "db_secrets_name" {
  description = "AWS Secrets Manager name for flask secrets"
  type        = string
}