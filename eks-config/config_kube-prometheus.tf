resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "-"
}

resource "aws_secretsmanager_secret" "grafana_password" {
  name = "${var.cluster_name}/grafana/administrator-password"
  #   kms_key_id = aws_kms_key.eks_kms_key.id
}

resource "aws_secretsmanager_secret_version" "grafana_password" {
  secret_id     = aws_secretsmanager_secret.grafana_password.id
  secret_string = random_password.grafana_password.result
}

resource "helm_release" "kube-prometheus" {
  count      = var.enable_kube_prometheus_stack ? 1 : 0
  name       = "kube-prometheus-stack"
  namespace  = "kube-prometheus-stack"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = var.kube_prometheus_stack_helm_chart_version

  create_namespace = true

  values = [<<-EOT
defaultRules:
  create: true
  rules:
    etcd: false
    kubeScheduler: false

kubeControllerManager:
  enabled: false
kubeEtcd:
  enabled: false
kubeScheduler:
  enabled: false

prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 100Gi
  
prometheusOperator:
  admissionWebhooks:
    failurePolicy: Ignore

grafana:
  enabled: true
  adminPassword: ${random_password.grafana_password.result}
  EOT
  ]
}


resource "helm_release" "loki" {
  count            = var.enable_kube_prometheus_stack ? 1 : 0
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  namespace        = "kube-prometheus-stack"
  version          = var.loki_helm_chart_version
  create_namespace = true

  values = [<<-EOT
loki:
  enabled: true
  isDefault: true

promtail:
  enabled: true

grafana:
  enabled: false

prometheus:
  enabled: false
  EOT
  ]
}
