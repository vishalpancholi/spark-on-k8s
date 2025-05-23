# Add security group rules to connect EKS with RDS
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.eks_node_security_group_id
  security_group_id        = var.rds_security_group_id
  description              = "MySQL from EKS nodes"
}