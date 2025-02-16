# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.86.1"
  }
  tls = {
    source  = "hashicorp/tls"
    version = "~> 4.0.0" # Specify the version as needed
  }
  time = {
    source  = "hashicorp/time"
    version = "~> 0.9.1" # Specify the version as needed
  }
  null = {
    source  = "hashicorp/null"
    version = "~> 3.2.1" # Specify the version as needed
  }
  cloudinit = {
    source  = "hashicorp/cloudinit"
    version = "~> 2.2.0" # Specify the version as needed
  }
  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.35.0"
  }
  kubectl = {
    source  = "alekc/kubectl"
    version = ">= 2.1.3"
  }
  helm = {
    source  = "hashicorp/helm"
    version = "~> 2.17.0"
  }
  random = {
    source  = "hashicorp/random"
    version = "~> 3.1.0"
  }
}

provider "aws" "main" {
  config {
    region = var.region

    assume_role_with_web_identity {
      role_arn           = var.role_arn
      web_identity_token = var.identity_token
    }

    default_tags {
      tags = var.default_tags
    }
  }
}

provider "aws" "global" {
  config {
    region = component.eks-config.global_region

    assume_role_with_web_identity {
      role_arn           = var.role_arn
      web_identity_token = var.identity_token
    }

    default_tags {
      tags = var.default_tags
    }
  }
}

provider "kubernetes" "main" {
  config {
    host                   = component.eks-cluster.cluster_endpoint
    cluster_ca_certificate = component.eks-cluster.cluster_ca
    token                  = component.eks-cluster.cluster_token
  }
}

provider "kubectl" "main" {
  config {
    host                   = component.eks-cluster.cluster_endpoint
    cluster_ca_certificate = component.eks-cluster.cluster_ca
    token                  = component.eks-cluster.cluster_token
    load_config_file       = false
  }
}

provider "helm" "main" {
  config {
    kubernetes {
      host                   = component.eks-cluster.cluster_endpoint
      cluster_ca_certificate = component.eks-cluster.cluster_ca
      token                  = component.eks-cluster.cluster_token
    }
  }
}

provider "tls" "main" {}

provider "null" "main" {}

provider "time" "main" {}

provider "cloudinit" "main" {}

provider "random" "main" {}


