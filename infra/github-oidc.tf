module "iam_oidc_provider_github" {
  source = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  url    = "https://token.actions.githubusercontent.com"
  tags   = { Project = local.project_tag }
}

data "aws_iam_policy_document" "gha_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.iam_oidc_provider_github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:iss"
      values   = ["https://token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

resource "aws_iam_role" "gha_terraform" {
  name                 = "gha-terraform"
  assume_role_policy   = data.aws_iam_policy_document.gha_assume_role.json
  max_session_duration = 3600
  tags                 = { Project = local.project_tag }
}

resource "aws_iam_role_policy_attachment" "gha_admin" {
  role       = aws_iam_role.gha_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_oidc_provider_arn" {
  value = module.iam_oidc_provider_github.arn
}

output "gha_terraform_role_arn" {
  value = aws_iam_role.gha_terraform.arn
}
