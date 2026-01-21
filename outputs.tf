output "cluster_name" {
  description = "Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "name" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}
