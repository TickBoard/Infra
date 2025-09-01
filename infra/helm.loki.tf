resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = var.loki_stack_version

  values = [yamlencode({
    loki = {
      persistence = {
        enabled = true
        size    = "20Gi"
      }
    }
    promtail = {
      enabled = true
    }
  })]

  depends_on = [
    module.vpc,
    module.eks
  ]
}

