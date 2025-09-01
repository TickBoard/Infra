resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "6.7.17"

  values = [yamlencode({
    applicationSet = {
      enabled = true
    }
    server = {
      replicas = 2
      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }
      serviceAccount = {
        create = true
        name   = "argocd-server"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.argocd_irsa.iam_role_arn
        }
      }
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
          "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
          "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
        }
      }
    }
  })]

  depends_on = [
    module.vpc,
    module.eks,
    module.alb_irsa
  ]
}
