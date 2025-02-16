module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33.1"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  create_kms_key                = true
  enable_kms_key_rotation       = true
  kms_key_administrators        = [one(data.aws_iam_roles.admin.arns)]
  kms_key_aliases               = ["${local.cluster_name}-kms-key"]
  kms_key_description           = "KMS Key used to encrypt ${local.cluster_name}"
  kms_key_enable_default_policy = true

  cluster_endpoint_private_access      = var.k8s_api_private_access
  cluster_endpoint_public_access       = var.k8s_api_public_access
  cluster_endpoint_public_access_cidrs = var.k8s_api_public_access_cidr_ranges

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  access_entries = {
    admin_role = {
      principal_arn = one(data.aws_iam_roles.admin.arns)
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    poweruser_role = {
      principal_arn = one(data.aws_iam_roles.poweruser.arns)
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    readonly_role = {
      principal_arn = one(data.aws_iam_roles.readonly.arns)
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

}



resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
}


