resource "helm_release" "argocd_apps" {
  count       = var.enable_argocd_apps ? 1 : 0
  name        = "argocd-apps"
  description = "ArgoCD Applications"
  namespace   = "argocd"
  chart       = "argocd-apps"
  version     = var.argocd_apps_helm_chart_version
  repository  = "https://argoproj.github.io/argo-helm"

  values = [<<-EOT
# -- Deploy Argo CD Applications within this helm release
# @default -- `{}` (See [values.yaml])
## Ref: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/
applications:
  workloads:
    namespace: argocd
    additionalLabels: {}
    additionalAnnotations: {}
    finalizers:
    - resources-finalizer.argocd.argoproj.io
    project: default
    source:
      repoURL: ${var.repo_url}             #git@github.com:<organization>/<repo_name>.git
      targetRevision: ${var.repo_branch}   #This is the branch name
      path: ${var.repo_path}               #This is the path
      directory:
        recurse: true
    destination:
      server: https://kubernetes.default.svc
      namespace: applications #This is the destination namespace
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      retry:
        backoff:
          duration: 10s
          factor: 2
          maxDuration: 3m
        limit: 10
      syncOptions:
      - Validate=false
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
      - RespectIgnoreDifferences=true
  EOT
  ]
}
