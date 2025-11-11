##############################################################################################
# Security Groups
##############################################################################################


##############################################################################################
# ALB_SG
##############################################################################################

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow inbound HTTP and HTTPS from the internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################################################################
# EKS SG
##############################################################################################

resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "EKS worker node security group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow traffic from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  ingress {
    description      = "Allow HTTPS traffic from ALB"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################################################################
# RDS SG
##############################################################################################

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow DB access from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    description      = "PostgreSQL access from EKS nodes"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.eks_nodes_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
