identity_token "aws" {
  audience = ["aws.workload.identity"]
}

deployment "development" {
  inputs = {
    region                            = "us-east-1"
    role_arn                          = "arn:aws:iam::999999999999:role/My_TrustPolicy_TerraformCloud"
    identity_token                    = identity_token.aws.jwt
    env                               = "dev"
    create_vpc                        = true
    project_name                      = "stacks-testing"
    environment                       = "dev"
    az_count                          = 3
    vpc_cidr                          = "10.0.0.0/16"
    enable_nat_gateway                = true
    cluster_version                   = "1.31"
    k8s_api_private_access            = true
    k8s_api_public_access             = true
    k8s_api_public_access_cidr_ranges = ["0.0.0.0/0"]



    enable_argocd                 = false
    enable_argocd_apps            = false
    enable_aws_cloudwatch_metrics = false
    enable_cert_manager           = false
    enable_external_secrets       = false
    enable_kube_prometheus_stack  = false
    enable_metrics_server         = false
    enable_ingress_nginx          = true
    enable_external_dns           = false
    enable_efs                    = false

    # Used for external-dns/not working yet
    r53_zone_ids = []

    external_albs = ["stacks.testing.com"] # Replace this domain with a domain you have a route53 hosted zone in the same account for
    private_albs  = []
    # external_albs = []
    # private_albs  = []
    private_alb_inbound_cidrs = [
      "0.0.0.0/0"
    ]

    #Change these to roles in your account to be set in EKS
    admin_role_name = "AdminRole"
    poweruser_role_name = "PowerUserRole"
    readonly_role_name = "ReadOnlyRole"


    # Not needed
    repo_url    = ""
    repo_branch = ""
    repo_path   = ""

  }
}

