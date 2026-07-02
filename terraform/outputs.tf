output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecr_registry" {
  description = "ECR Registry URL"
  value       = split("/", aws_ecr_repository.frontend.repository_url)[0]
}

output "ecr_frontend_uri" {
  description = "Frontend ECR URI"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_uri" {
  description = "Backend ECR URI"
  value       = aws_ecr_repository.backend.repository_url
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
