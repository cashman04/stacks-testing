data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_roles" "admin" {
  name_regex = "${var.admin_role_name}*"
}
