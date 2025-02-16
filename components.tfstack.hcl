component "vpc" {
  source = "./vpc"

  providers = {
    aws = provider.aws.main
  }

  inputs = {
    az_count            = var.az_count
    admin_role_name     = var.admin_role_name
    poweruser_role_name = var.poweruser_role_name
    readonly_role_name  = var.readonly_role_name
    project_name        = var.project_name
    environment         = var.environment
    create_vpc          = var.create_vpc
    name                = "${var.project_name}-${var.environment}"
    region              = var.region
    az_count            = var.az_count
    cidr                = var.vpc_cidr

  }
}

component "eks-cluster" {
  source = "./eks-cluster"

  providers = {
    aws       = provider.aws.main
    tls       = provider.tls.main
    null      = provider.null.main
    time      = provider.time.main
    cloudinit = provider.cloudinit.main
  }

  inputs = {
    project_name                         = var.project_name
    environment                          = var.environment
    cluster_version                      = var.cluster_version
    vpc_id                               = var.create_vpc ? component.vpc.vpc_id : var.vpc_id
    subnet_ids                           = var.create_vpc ? component.vpc.private_subnets : var.private_subnets
    cluster_endpoint_private_access      = var.k8s_api_private_access
    cluster_endpoint_public_access       = var.k8s_api_public_access
    cluster_endpoint_public_access_cidrs = var.k8s_api_public_access_cidr_ranges
    admin_role_name                      = var.admin_role_name
    poweruser_role_name                  = var.poweruser_role_name
    readonly_role_name                   = var.readonly_role_name
    k8s_api_private_access               = true
    k8s_api_public_access                = true
    k8s_api_public_access_cidr_ranges    = ["0.0.0.0/0"]

    authentication_mode                      = "API"
    enable_cluster_creator_admin_permissions = false
    create_service_linked_role               = true
  }
}

component "eks-config" {
  source = "./eks-config"

  providers = {
    kubectl    = provider.kubectl.main
    aws        = provider.aws.main
    kubernetes = provider.kubernetes.main
    helm       = provider.helm.main
    random     = provider.random.main
    null       = provider.null.main
    time       = provider.time.main
  }

  inputs = {
    cluster_name            = component.eks-cluster.cluster_name
    cluster_endpoint        = component.eks-cluster.cluster_endpoint
    cluster_version         = component.eks-cluster.cluster_version
    oidc_provider_arn       = component.eks-cluster.oidc_provider_arn
    cluster_oidc_issuer_url = component.eks-cluster.cluster_oidc_issuer_url
    cluster_iam_role_arn    = component.eks-cluster.cluster_iam_role_arn
    private_subnets         = component.vpc.private_subnets
    vpc_id                  = component.vpc.vpc_id
    vpc_cidr_block          = component.vpc.vpc_cidr_block
    admin_role_name         = var.admin_role_name

    enable_argocd                 = var.enable_argocd
    enable_argocd_apps            = var.enable_argocd_apps
    enable_aws_cloudwatch_metrics = var.enable_aws_cloudwatch_metrics
    enable_cert_manager           = var.enable_cert_manager
    enable_external_secrets       = var.enable_external_secrets
    enable_kube_prometheus_stack  = var.enable_kube_prometheus_stack
    enable_metrics_server         = var.enable_metrics_server
    enable_ingress_nginx          = var.enable_ingress_nginx
    enable_external_dns           = var.enable_external_dns
    enable_efs                    = var.enable_efs

    argocd_helm_chart_version                       = "7.8.2"
    aws_cloudwatch_metrics_helm_chart_version       = "0.0.11"
    aws_load_balancer_controller_helm_chart_version = "1.11.0"
    external_dns_helm_chart_version                 = "1.14.5"
    cert_manager_helm_chart_version                 = "v1.14.4" #Its published with a v in front. So the v is required
    cluster_autoscaler_helm_chart_version           = "9.36.0"
    external_secrets_helm_chart_version             = "0.9.16"
    kube_prometheus_stack_helm_chart_version        = "58.1.3"
    kubnerenetes_dashboard_helm_chart_version       = "6.0.0"
    argocd_apps_helm_chart_version                  = "2.0.0"
    ingress_nginx_helm_chart_version                = "4.6.1"
    istio_base_helm_chart_version                   = "1.21.2"
    istio_cni_helm_chart_version                    = "1.21.2"
    istio_istiod_helm_chart_version                 = "1.21.2"
    istio_gateway_helm_chart_version                = "1.21.2"
    consul_helm_chart_version                       = "1.4.1"
    datadog_helm_chart_version                      = "3.59.6"
    metrics_server_helm_chart_version               = "3.12.0"
    loki_helm_chart_version                         = "2.10.2"
    r53_zone_ids                                    = var.r53_zone_ids
    external_albs                                   = var.external_albs
    private_albs                                    = var.private_albs
    private_alb_inbound_cidrs                       = var.private_alb_inbound_cidrs

    repo_url    = var.repo_url
    repo_branch = var.repo_branch
    repo_path   = var.repo_path

  }

}



# component "cloudfront" {
#   source = "./cloudfront"

#   providers = {
#     aws = provider.aws.global
#   }

#   inputs = {
#     external_albs = var.external_albs
#   }

# }


# removed {
#   from   = component.eks-config
#   source = "./eks-config"

#   providers = {
#     kubectl = provider.kubectl.main
#     aws     = provider.aws.main
#     # time       = provider.time.main
#     kubernetes = provider.kubernetes.main
#     helm       = provider.helm.main
#     random     = provider.random.main
#   }



# }







# component "blueprint" {
#   source  = "aws-ia/eks-blueprints-addons/aws"
#   version = "1.16.3"

#   providers = {
#     kubectl    = provider.kubectl.main
#     aws        = provider.aws.main
#     time       = provider.time.main
#     kubernetes = provider.kubernetes.main
#     helm       = provider.helm.main
#   }

#   inputs = {
#     cluster_name      = component.eks-cluster.cluster_name
#     cluster_endpoint  = component.eks-cluster.cluster_endpoint
#     cluster_version   = component.eks-cluster.cluster_version
#     oidc_provider_arn = component.eks-cluster.oidc_provider_arn

#     enable_argocd                       = false
#     enable_aws_cloudwatch_metrics       = false
#     enable_aws_load_balancer_controller = false
#     enable_cert_manager                 = false
#     enable_external_secrets             = false
#     enable_kube_prometheus_stack        = false
#     enable_metrics_server               = false
#     enable_ingress_nginx                = false
#     enable_external_dns                 = false

#     # external_albs = ["nonprod.rd12.recreation-management.tylerapp.com"]
#     r53_zone_ids = ["Z10041702K8K9Z3AVY1V1"]

#     external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/Z10041702K8K9Z3AVY1V1"]
#     external_dns = {
#       chart_version          = "1.14.5"
#       role_name              = "stacks-testing-dev-external-dns-iam-role"
#       role_name_use_prefix   = false
#       policy_name            = "stacks-testing-dev-external-dns-iam-policy"
#       policy_name_use_prefix = false
#       domainfilters          = ["nonprod.rd12.recreation-management.tylerapp.com"]
#       set = [
#         {
#           name  = "extraArgs[0]"
#           value = "--source=ingress"
#         },
#         {
#           name  = "extraArgs[1]"
#           value = "--ingress-class=alb"
#         }
#       ]
#     }
#   }

# }


# removed {
#   source = "./eks-config"


#   from = component.eks-config
#   providers = {
#     kubectl    = provider.kubectl.main
#     aws        = provider.aws.main
#     time       = provider.time.main
#     kubernetes = provider.kubernetes.main
#     helm       = provider.helm.main
#     random     = provider.random.main
#   }

# }


# removed {
#   source = "./efs"

#   providers = {
#     aws = provider.aws.main
#   }


#   from = component.efs
# }




