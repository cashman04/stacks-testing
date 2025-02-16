variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  type        = string
  description = "Version of the EKS cluster"
}

variable "region" {
  type        = string
  description = "AWS region for the EKS deployment"
  default     = "us-west-2"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to use for EKS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the worker nodes"
}

variable "instance_type" {
  type        = string
  description = "Instance type for worker nodes"
  default     = "t3.medium"
}

variable "admin_role_name" {
  type        = string
  description = "Name of the admin role"
}

variable "poweruser_role_name" {
  type        = string
  description = "Name of the poweruser role"
}

variable "readonly_role_name" {
  type        = string
  description = "Name of the readonly role"
}

variable "k8s_api_private_access" {
  type        = bool
  description = "Enable private access to the EKS API server"
}

variable "k8s_api_public_access" {
  type        = bool
  description = "Enable public access to the EKS API server"
}

variable "k8s_api_public_access_cidr_ranges" {
  type        = list(string)
  description = "CIDR blocks for public access to the EKS API server"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "create_service_linked_role" {
  type        = bool
  description = "Create service linked role for EKS"
}
