module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                       = var.cluster_name
  kubernetes_version         = var.k8s_version
  endpoint_public_access     = true

  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnets
  control_plane_subnet_ids   = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  create_cloudwatch_log_group = false 

  create_kms_key   = false
  attach_encryption_policy = false   

  encryption_config = {
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }

  tags = { Project = var.project }

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
      subnet_ids     = module.vpc.private_subnets
    }
  }

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = { before_compute = true }
  }
}

resource "aws_eks_access_entry" "gha" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_actions_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "gha_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_actions_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.gha]
}
