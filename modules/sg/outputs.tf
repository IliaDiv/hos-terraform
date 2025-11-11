output "alb_sg_id" {
    description = "the id of the ALB SG"
    value = aws_security_group.alb_sg.id
}

output "eks_nodes_sg_id" {
    description = "the id of the EKS nodes SG"
    value = aws_security_group.eks_nodes_sg.id
}

output "rds_sg_id" {
    description = "the id of the RDS SG"
    value = aws_security_group.rds_sg.id
}