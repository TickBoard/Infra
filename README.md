Infrastructure (Terraform)
-------------------------

What it does
- Provisions a minimal VPC + EKS cluster (managed node group).
- Installs Argo CD via Helm with `argocd-server` exposed as `Service` type `LoadBalancer`.

Requirements
- Terraform >= 1.6
- AWS CLI configured (`aws_profile`), kubectl

Key files
- `versions.tf`, `providers.tf`
- `vpc.tf`, `eks.tf`
- `argocd.tf`
- `outputs.tf`, `kubeauth.tf`

Variables (see `infra/variables.tf`)
- `project`, `aws_region`, `aws_profile`, `cluster_name`, `k8s_version`

Usage
1) Copy `infra/terraform.tfvars.example` to `infra/terraform.tfvars` and adjust values.
2) `terraform -chdir=infra init`
3) `terraform -chdir=infra apply`

After apply
- Get Argo CD server external address (may take 1–3 minutes):
  - `kubectl get svc -n argocd argocd-server -o wide`
  - or via label: `kubectl get svc -n argocd -l app.kubernetes.io/name=argocd-server -o wide`
