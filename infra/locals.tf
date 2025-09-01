locals {
  project_tag = "sideproj-eks"
  tags = {
    Project = local.project_tag
    Owner   = "czhuang"
  }
  
  github_subjects = [
    "repo:ChongZhe001025/EKS-side-project:ref:refs/heads/main",
  ]
}
