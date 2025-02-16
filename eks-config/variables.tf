variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
}


variable "enable_argocd" {
  type        = bool
  description = "Enable ArgoCD"
}

variable "enable_aws_cloudwatch_metrics" {
  type        = bool
  description = "Enable AWS CloudWatch Metrics"
}

variable "enable_cert_manager" {
  type        = bool
  description = "Enable Cert Manager"
}

variable "enable_external_secrets" {
  type        = bool
  description = "Enable External Secrets"
}

variable "enable_kube_prometheus_stack" {
  type        = bool
  description = "Enable Kube Prometheus Stack"
}

variable "enable_metrics_server" {
  type        = bool
  description = "Enable Metrics Server"
}

variable "enable_ingress_nginx" {
  type        = bool
  description = "Enable Ingress NGINX"
}

variable "enable_external_dns" {
  type        = bool
  description = "Enable External DNS"
}

variable "enable_argocd_apps" {
  type        = bool
  description = "Enable ArgoCD Apps"
}

variable "argocd_helm_chart_version" {
  type        = string
  description = "ArgoCD Helm chart version"
}

variable "aws_cloudwatch_metrics_helm_chart_version" {
  type        = string
  description = "AWS CloudWatch Metrics Helm chart version"
}

variable "aws_load_balancer_controller_helm_chart_version" {
  type        = string
  description = "AWS Load Balancer Controller Helm chart version"
}

variable "external_dns_helm_chart_version" {
  type        = string
  description = "External DNS Helm chart version"
}

variable "cert_manager_helm_chart_version" {
  type        = string
  description = "Cert Manager Helm chart version"
}

variable "cluster_autoscaler_helm_chart_version" {
  type        = string
  description = "Cluster Autoscaler Helm chart version"
}

variable "external_secrets_helm_chart_version" {
  type        = string
  description = "External Secrets Helm chart version"
}

variable "kube_prometheus_stack_helm_chart_version" {
  type        = string
  description = "Kube Prometheus Stack Helm chart version"
}

variable "kubnerenetes_dashboard_helm_chart_version" {
  type        = string
  description = "Kubernetes Dashboard Helm chart version"
}

variable "argocd_apps_helm_chart_version" {
  type        = string
  description = "ArgoCD Apps Helm chart version"
}

variable "ingress_nginx_helm_chart_version" {
  type        = string
  description = "Ingress NGINX Helm chart version"
}

variable "istio_base_helm_chart_version" {
  type        = string
  description = "Istio Base Helm chart version"
}

variable "istio_cni_helm_chart_version" {
  type        = string
  description = "Istio CNI Helm chart version"
}

variable "istio_istiod_helm_chart_version" {
  type        = string
  description = "Istio Istiod Helm chart version"
}

variable "istio_gateway_helm_chart_version" {
  type        = string
  description = "Istio Gateway Helm chart version"
}

variable "consul_helm_chart_version" {
  type        = string
  description = "Consul Helm chart version"
}

variable "datadog_helm_chart_version" {
  type        = string
  description = "Datadog Helm chart version"
}

variable "metrics_server_helm_chart_version" {
  type        = string
  description = "Metrics Server Helm chart version"
}

variable "loki_helm_chart_version" {
  type        = string
  description = "Loki Helm chart version"
}



### Temp for external-dns
variable "r53_zone_ids" {
  type        = list(string)
  description = "Route53 Zone IDs"
}

# variable "main_app_apex_zone" {
#   type        = string
#   description = "Main application apex zone"
# }




### Ingress ALB's
variable "external_albs" {
  type        = list(string)
  description = "List of external ALBs"
}

### EFS
variable "enable_efs" {
  description = "Enable EFS"
  type        = bool
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the worker nodes"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC to use for EKS"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "cluster_iam_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "private_albs" {
  description = "List of private ALBs"
  type        = list(string)
}

variable "private_alb_inbound_cidrs" {
  description = "List of CIDR blocks to allow inbound traffic to the private ALBs"
  type        = list(string)
}

variable "admin_role_name" {
  description = "Name of the admin role"
  type        = string
}

### Argo CD Apps
variable "repo_url" {
  type        = string
  description = "URL of the Git repository"
}

variable "repo_branch" {
  type        = string
  description = "Branch name of the Git repository"
}

variable "repo_path" {
  type        = string
  description = "Path name of the Git repository"
}

