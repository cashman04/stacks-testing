data "aws_iam_roles" "admin" {
  name_regex = "${var.admin_role_name}*"
}

data "aws_iam_roles" "poweruser" {
  name_regex = "${var.poweruser_role_name}*"
}

data "aws_iam_roles" "readonly" {
  name_regex = "${var.readonly_role_name}*"
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}
