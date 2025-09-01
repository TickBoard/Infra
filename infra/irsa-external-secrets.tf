data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eso_read" {
  statement {
    sid     = "SecretsManagerRead"
    effect  = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:*"
    ]
  }

  statement {
    sid     = "SSMParameterRead"
    effect  = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParameterHistory",
      "ssm:DescribeParameters"
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }

  # Note: Add kms:Decrypt for CMK-encrypted SSM/Secrets if needed.
}

resource "aws_iam_policy" "eso_read" {
  name        = "${var.cluster_name}-eso-read"
  description = "Read-only access for External Secrets Operator to AWS SM/SSM"
  policy      = data.aws_iam_policy_document.eso_read.json
  tags        = local.tags
}

module "external_secrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  create_role = true
  role_name   = "${var.cluster_name}-external-secrets"

  role_policy_arns = {
    eso = aws_iam_policy.eso_read.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  tags = local.tags
}

