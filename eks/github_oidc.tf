module "github_oidc" {
  source = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"
  url    = "https://token.actions.githubusercontent.com"
  tags   = { Project = var.project }
}


data "aws_iam_policy_document" "gha_eks_describe" {
  statement {
    actions   = ["eks:DescribeCluster", "eks:ListClusters"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "gha_eks_describe" {
  name   = "gha-eks-describe"
  policy = data.aws_iam_policy_document.gha_eks_describe.json
}


module "github_actions_role" {
  source              = "terraform-aws-modules/iam/aws//modules/iam-role"

  name                = var.github_role_name
  enable_github_oidc  = true
  oidc_subjects       = var.github_oidc_subjects 

  policies = {
    EksDescribe = aws_iam_policy.gha_eks_describe.arn
  }

  tags       = { Project = var.project }
  depends_on = [module.github_oidc] 
}

