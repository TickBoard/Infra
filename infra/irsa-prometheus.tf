data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "amp_remote_write" {
  statement {
    sid     = "AllowAMPRemoteWrite"
    effect  = "Allow"
    actions = [
      "aps:RemoteWrite",
      "aps:DescribeWorkspace",
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]
    resources = [
      "arn:aws:aps:${var.aws_region}:${data.aws_caller_identity.current.account_id}:workspace/${var.amp_workspace_id}"
    ]
  }
}

resource "aws_iam_policy" "amp_remote_write" {
  name        = "${var.cluster_name}-amp-remote-write"
  description = "Allow Prometheus to remote_write to AMP workspace ${var.amp_workspace_id}"
  policy      = data.aws_iam_policy_document.amp_remote_write.json
}

module "prometheus_amp_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  create_role      = true
  role_name        = "${var.cluster_name}-prometheus-amp"

  role_policy_arns = {
    amp = aws_iam_policy.amp_remote_write.arn
  }

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["monitoring:kube-prometheus-stack-prometheus"]
    }
  }

  tags = local.tags
}

