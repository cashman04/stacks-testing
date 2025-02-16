resource "helm_release" "metrics-server" {
  count      = var.enable_metrics_server ? 1 : 0
  name       = "metrics-server"
  namespace  = "kube-system"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = var.metrics_server_helm_chart_version

  create_namespace = true

}
