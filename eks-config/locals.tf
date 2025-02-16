locals {
  create_efs_irsa = var.enable_efs ? 1 : 0
}
