resource "helm_release" "ingress-nginx" {
  count      = var.enable_ingress_nginx ? 1 : 0
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = var.ingress_nginx_helm_chart_version

  create_namespace = true

  values = [<<-EOT
controller:
  ingressClassResource:
    name: nginx
    default: false
  kind: DaemonSet
  service:
    type: NodePort
  EOT
  ]

}
