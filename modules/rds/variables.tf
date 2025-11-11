# RDS-POSTGRES

variable "identifier" {
    description = "the RDS POSTGRES engine version to use"
    type = string
}

variable "engine_version" {
    description = "the RDS POSTGRES engine version to use"
    type = string
}

variable "allocated_storage" {
    description = "how many GB storage RDS POSTGRES gets"
    type = number
}

variable "vpc_security_group_ids"{
    type = list(string)
}

variable "postgres_tags" {
    description = "Tags of the POSTGRES instance"
    type        = map(string)
}

variable "rds_subnet_ids" {
  description = "the private subnets ids to host the POSTGRES instances in"
  type = list(string)
}

variable "family" {
    description = "POSTGRES family"
    type = string
}

variable "major_engine_version" {
    description = "the RDS POSTGRES MAJOR engine version to use"
    type = string
}

