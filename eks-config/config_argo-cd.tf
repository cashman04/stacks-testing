resource "random_password" "argocd_password" {
  length           = 16
  special          = true
  override_special = "-"
}

resource "aws_secretsmanager_secret" "argocd_password" {
  name = "${var.cluster_name}/argocd/administrator-password"
  #   kms_key_id = aws_kms_key.eks_kms_key.id
}

resource "aws_secretsmanager_secret_version" "argocd_password" {
  secret_id     = aws_secretsmanager_secret.argocd_password.id
  secret_string = random_password.argocd_password.result
}


resource "helm_release" "argo-cd" {
  count      = var.enable_argocd ? 1 : 0
  name       = "argo-cd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argocd_helm_chart_version

  create_namespace = true

  values = [<<-EOT
  redis-ha:
    enabled: true
  controller:
    enableStatefulSet: true
  server:
    autoscaling:
      enabled: true
      minReplicas: 2
    extraArgs:
      - --insecure
  repoServer:
    autoscaling:
      enabled: true
      minReplicas: 2
  configs:
    cm:
      timeout.reconciliation: 10s
      accounts.devuser: apiKey, login
    rbac:
      policy.csv: |
        p, role:readonly, applications, get, */*, allow
        p, role:readonly, certificates, get, *, allow
        p, role:readonly, clusters, get, *, allow
        p, role:readonly, repositories, get, *, allow
        p, role:readonly, projects, get, *, allow
        p, role:readonly, accounts, get, *, allow
        p, role:readonly, gpgkeys, get, *, allow
        p, role:readonly, logs, get, */*, allow
        g, devuser, role:readonly
  notifications:
    logLevel: "debug"
    EOT
  ]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(random_password.argocd_password.result)
  }

  lifecycle {
    ignore_changes = [metadata, set_sensitive]
  }
}


resource "kubernetes_manifest" "argocd_ingress" {
  for_each = toset(var.private_albs)
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "argocd-ingress"
      namespace = "argocd"
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
      }
    }
    spec = {
      rules = [
        {
          host = "argocd.${each.value}"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "argo-cd-argocd-server"
                    port = {
                      number = 443
                    }
                  }
                }
              }
            ]
          }
        }
      ]
      ingressClassName = "nginx"
    }
  }
}
