### Providers

variable "role_arn" {
  type = string
}

variable "identity_token" {
  type      = string
  ephemeral = true
}



###  VPC

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "default_tags" {
  description = "A map of default tags to apply to all AWS resources"
  type        = map(string)
  default     = {}
}

variable "az_count" {
  type    = number
  default = 3
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Create VPC"
  type        = bool
  default     = true
}


variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "ID of the VPC to use"
  type        = string
  default     = ""
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "admin_role_name" {
  type        = string
  description = "IAM Role name for Administrator Permissions"
  default     = "AWSReservedSSO_DSD_AdministratorAccess"
}

variable "poweruser_role_name" {
  type        = string
  description = "IAM Role name for PowerUser Permissions"
  default     = "AWSReservedSSO_DSD_PowerUserAccess"
}

variable "readonly_role_name" {
  type        = string
  description = "IAM Role name for ReadOnly Permissions"
  default     = "AWSReservedSSO_DSD_ReadOnlyAccess"
}



### EKS

variable "k8s_api_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
}

variable "k8s_api_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
}

variable "k8s_api_public_access_cidr_ranges" {
  type        = list(string)
  description = "List of CIDR blocks to allow public access to the k8s API server"
}




### EFS
variable "enable_efs" {
  type        = bool
  description = "Enable EFS"
  default     = false
}


### EKS Cluster
variable "enable_argocd" {
  type        = bool
  description = "Enable ArgoCD"
}

variable "enable_argocd_apps" {
  type        = bool
  description = "Enable ArgoCD Apps"
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


## External-dns
variable "r53_zone_ids" {
  type        = list(string)
  description = "Route53 Zone IDs"
}


## Ingress-ALBs

variable "external_albs" {
  type        = list(string)
  description = "List of external ALBs"
}

variable "private_albs" {
  description = "List of private ALBs"
  type        = list(string)
}

variable "private_alb_inbound_cidrs" {
  description = "List of CIDR blocks to allow inbound traffic to the private ALBs"
  type        = list(string)
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
