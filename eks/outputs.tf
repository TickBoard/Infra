# EKS / VPC
output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API server endpoint"
  sensitive   = true
}

output "cluster_ca_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "Base64-encoded cluster CA data"
  sensitive   = true
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID used by the cluster"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs for worker nodes / control plane"
}

output "github_actions_role_arn" {
  value       = module.github_actions_role.arn
  description = "IAM Role ARN (assumed by GitHub OIDC). Set this as AWS_GHA_ROLE_ARN in GitHub Secrets."
}

output "github_oidc_provider_arn" {
  value       = module.github_oidc.arn
  description = "GitHub OIDC provider ARN (token.actions.githubusercontent.com)"
}

output "gha_principal_arn_in_eks" {
  value       = try(aws_eks_access_entry.gha.principal_arn, null)
  description = "Principal ARN registered in EKS access entries (should equal the GitHub Actions role ARN)."
}

output "gha_access_policy_arn" {
  value       = try(aws_eks_access_policy_association.gha_admin.policy_arn, null)
  description = "EKS access policy associated with the GitHub Actions role (e.g., AmazonEKSClusterAdminPolicy)."
}
