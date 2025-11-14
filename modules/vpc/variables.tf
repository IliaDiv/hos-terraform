# VPC
variable "region" {
  type = string
}

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
