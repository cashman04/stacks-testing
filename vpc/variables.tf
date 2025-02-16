variable "region" {
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
}

variable "poweruser_role_name" {
  type        = string
  description = "IAM Role name for PowerUser Permissions"
}

variable "readonly_role_name" {
  type        = string
  description = "IAM Role name for ReadOnly Permissions"
}
