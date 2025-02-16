output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca" {
  value = base64decode(module.eks.cluster_certificate_authority_data)
}

output "cluster_token" {
  sensitive = true
  value     = data.aws_eks_cluster_auth.eks.token
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "global_region" {
  value = "us-east-1"
}
