module "efs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [one(data.aws_iam_roles.admin.arns)]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    var.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${var.cluster_name}/efs"]
}

resource "aws_efs_file_system" "efs" {
  count          = var.enable_efs ? 1 : 0
  creation_token = "${var.cluster_name}-efs"
  encrypted      = true
  kms_key_id     = module.efs_kms_key.key_arn

  #   lifecycle_policy {
  #     transition_to_ia = "AFTER_30_DAYS" # Optionally enable lifecycle management
  #   }
  tags = {
    Name = "${var.cluster_name}-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  count           = var.enable_efs ? length(var.private_subnets) : 0
  file_system_id  = aws_efs_file_system.efs[0].id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg[0].id]
}

module "efs_csi_driver_irsa" {
  count                         = local.create_efs_irsa
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-eks-efs-csi-driver-irsa-role"
  provider_url                  = var.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]

  inline_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "elasticfilesystem:*"
      ]
      resources = [aws_efs_file_system.efs[0].arn]
    }
  ]
}



resource "aws_security_group" "efs_sg" {
  count       = var.enable_efs ? 1 : 0
  name        = "${var.cluster_name}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  # Inbound rules to allow NFS traffic from the EKS nodes
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    description = "Allow NFS traffic"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Outbound rules (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-efs-sg"
  }
}

resource "kubernetes_manifest" "efs_storage_class" {
  count = var.enable_efs ? 1 : 0
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind"       = "StorageClass"
    "metadata" = {
      "name" = "efs-sc"
      "annotations" = {
        "storageclass.beta.kubernetes.io/is-default-class" = "false"
      }
    }
    "provisioner" = "efs.csi.aws.com"
    "parameters" = {
      "fileSystemId"     = aws_efs_file_system.efs[0].id
      "directoryPerms"   = "700"
      "provisioningMode" = "efs-ap"
    }
    "mountOptions"      = ["tls"]
    "reclaimPolicy"     = "Retain"
    "volumeBindingMode" = "WaitForFirstConsumer"
  }
}
