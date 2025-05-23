output "security_rule_id" {
    description = "The ID of the security group rule"
    value       = aws_security_group_rule.eks_to_rds.id
  }