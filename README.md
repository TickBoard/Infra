Infrastructure (Terraform)
-------------------------

What it does
- Provisions EKS and core IAM/IRSA.
- Installs cluster add‑ons via Helm: ALB Controller, Argo CD, kube‑prometheus‑stack, loki‑stack.
- Bootstraps Argo CD Root Application with `kubernetes_manifest`.

Requirements
- Terraform >= 1.6
- AWS CLI configured (`aws_profile`), kubectl

Key files
- `providers.tf`: AWS, Kubernetes, Helm providers (with `manifest_resource` enabled for bootstrap).
- `eks.tf`, `vpc.tf`: Core infra.
- `irsa-*.tf`: IRSA roles for add‑ons.
- `helm.*.tf`: Helm releases for add‑ons.
- `bootstrap.argocd.tf`: Applies `gitops/apps/root-app.yaml` once Argo is installed.

Variables (see `variables.tf`)
- `aws_region`, `aws_profile`, `cluster_name`
- `enable_amp_remote_write`, `amp_workspace_id`
- `kps_version`, `loki_stack_version`

Usage
1) Copy `terraform.tfvars.example` to `terraform.tfvars` and adjust values.
2) `terraform init`
3) `terraform apply`

Notes
- Grafana Ingress hostname is set in `helm.prometheus.tf` (`grafana.czhuang.dev`). Update to your domain if needed.
- After apply, Argo CD Root App will start syncing manifests from `gitops/stacks/**`.

