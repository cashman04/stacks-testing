module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"
  name    = "${var.project_name}-${var.environment}-vpc"
  cidr    = var.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 5, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 24)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 28)]
  #   elasticache_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 32)]

  private_subnet_names  = [for az in local.azs : "${var.project_name}-${var.environment}-private-subnet-${az}"]
  public_subnet_names   = [for az in local.azs : "${var.project_name}-${var.environment}-public-subnet-${az}"]
  database_subnet_names = [for az in local.azs : "${var.project_name}-${var.environment}-database-subnet-${az}"]


  create_database_subnet_group  = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = false

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

}
