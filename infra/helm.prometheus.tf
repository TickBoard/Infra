resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kps_version

  values = [yamlencode({
    prometheus = {
      serviceAccount = merge(
        {
          create = true
          name   = "kube-prometheus-stack-prometheus"
        },
        var.enable_amp_remote_write ? {
          annotations = {
            "eks.amazonaws.com/role-arn" = module.prometheus_amp_irsa.iam_role_arn
          }
        } : {}
      )

      prometheusSpec = {
        serviceMonitorSelectorNilUsesHelmValues = false
        podMonitorSelectorNilUsesHelmValues     = false

        remoteWrite = var.enable_amp_remote_write ? [
          {
            url   = "https://aps.${var.aws_region}.amazonaws.com/workspaces/${var.amp_workspace_id}/api/v1/remote_write"
            sigv4 = { region = var.aws_region }
            queue_config = {
              max_samples_per_send = 1000
              max_shards           = 200
              capacity             = 5000
            }
          }
        ] : []
      }
    }

    grafana = {
      enabled = true
      service = { type = "ClusterIP" }
      ingress = {
        enabled          = true
        ingressClassName = "alb"
        annotations = {
          "kubernetes.io/ingress.class"             = "alb"
          "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
        }
        hosts = [
          "grafana.czhuang.dev"
        ]
      }
    }

    alertmanager = {
      enabled = true
      service = { type = "ClusterIP" }
    }
  })]

  depends_on = [
    module.vpc,
    module.eks,
    module.alb_irsa
  ]
}
