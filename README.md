TickBoard Infra (Terraform for AWS EKS)
======================================

This repository provisions a minimal yet production‑leaning AWS EKS environment with Terraform and installs core components for GitOps and ingress. It also includes a GitHub Actions OIDC integration to enable CI/CD with least‑privilege, short‑lived credentials.

What this provides
- VPC with public/private subnets, NAT, and ELB tags
- EKS cluster (managed node group, core addons, secrets encryption via KMS)
- GitHub OIDC provider + IAM role restricted by allowed `sub` values
- EKS access entry + cluster admin access policy for the GitHub Actions role
- Argo CD via Helm with `argocd-server` exposed as `LoadBalancer`
- AWS Load Balancer Controller via IRSA + Helm

Terraform code lives under `eks/`.

Repository layout
- `eks/versions.tf`: Terraform and provider version constraints
- `eks/providers.tf`: `aws`, `kubernetes`, and `helm` providers bound to the new EKS cluster
- `eks/variables.tf`: All input variables (project, region, cluster, KMS, GitHub OIDC, etc.)
- `eks/vpc.tf`: VPC module with subnets and required Kubernetes ELB tags
- `eks/eks.tf`: EKS module, managed node group, addons, secrets encryption, and EKS access entries
- `eks/argocd.tf`: Argo CD Helm release; server Service type `LoadBalancer`
- `eks/alb_controller.tf`: AWS Load Balancer Controller (IRSA + Helm)
- `eks/github_oidc.tf`: GitHub OIDC provider and GitHub Actions role
- `eks/outputs.tf`: Outputs for EKS, VPC, and GitHub OIDC/IAM integration
- `eks/terraform.tfvars.example`: Example variables file

Requirements
- Terraform >= 1.6
- AWS CLI configured (matching `aws_profile`), kubectl
- Adequate AWS permissions to create VPC, EKS, IAM/OIDC, and ALB resources
- Optional: Helm CLI (not required if only using Terraform’s Helm provider)

Important defaults & notes
- Kubernetes version defaults to `1.30` (`eks/variables.tf`).
- Region defaults to `ap-southeast-2`.
- `kms_key_arn` defaults to an example ARN from another account. Replace it with your own KMS key ARN in the same region/account to enable EKS secret encryption. If you don’t want secret encryption, adjust `eks/eks.tf` to remove the encryption config.
- Subnet tags for ELB are pre‑configured in `eks/vpc.tf` for compatibility with Kubernetes Services/Ingress.
- The Argo CD server runs behind a `LoadBalancer` Service. External hostname may take 1–3 minutes to appear.

Quick start
1) Copy variables template and edit values
   - `cp eks/terraform.tfvars.example eks/terraform.tfvars`
   - Set `project`, `aws_region`, `aws_profile`, `cluster_name`, `k8s_version`
   - Set `kms_key_arn` to a valid key in your account/region (or remove encryption)
   - Set `github_oidc_subjects` to the allowed GitHub `sub` patterns (see examples below)

2) Initialize and apply
   - `terraform -chdir=eks init`
   - `terraform -chdir=eks apply`

3) Configure local kubeconfig
   - `aws eks update-kubeconfig --name <cluster_name> --region <aws_region> --profile <aws_profile>`

4) Verify Argo CD
   - `kubectl get ns`
   - `kubectl get svc -n argocd argocd-server -o wide`

GitHub Actions OIDC
- Terraform creates:
  - A GitHub OIDC provider (`https://token.actions.githubusercontent.com`)
  - An IAM role (default name `gha-deploy`) restricted by `github_oidc_subjects`
  - An EKS access entry + `AmazonEKSClusterAdminPolicy` association for that role
- Outputs include `github_actions_role_arn` and `github_oidc_provider_arn`. Store the role ARN in GitHub Secrets, e.g. `AWS_GHA_ROLE_ARN`.
- Common `sub` patterns for `github_oidc_subjects`:
  - `repo:OWNER/REPO:ref:refs/heads/main` (specific branch)
  - `repo:OWNER/REPO:pull_request` (any PR)
  - `repo:OWNER/REPO:environment:prod` (specific environment)

Example GitHub workflow (snippet)
```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_GHA_ROLE_ARN }}
          aws-region: ap-southeast-2
      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --name sideproj-eks --region ap-southeast-2
      - name: Validate access
        run: kubectl get nodes -o wide
```

Managing changes
- First‑time deploy: `terraform -chdir=eks apply`
- Update changes: edit `.tf` or `.tfvars`, then `terraform -chdir=eks apply`
- View outputs: `terraform -chdir=eks output`

Destroy
- If deletion is blocked by external load balancers:
  - Delete Services/Ingresses that create external LBs (e.g., Argo CD `argocd-server`).
  - Ensure no leftover Target Groups or ALB Listeners remain in AWS.
- Destroy everything: `terraform -chdir=eks destroy`

Troubleshooting
- KMS errors/ARN mismatch: Replace `kms_key_arn` with a valid key (same account/region) or remove encryption.
- Existing GitHub OIDC provider: If your org already has one, reuse it or adjust the module configuration to avoid conflicts.
- Argo CD external address pending: Wait 1–3 minutes; verify subnet tags and Service type.
- `kubectl` cannot connect: Re‑run `aws eks update-kubeconfig` with the correct profile/region/cluster name.
- ALB Controller issues: Check the Pod in `kube-system`, IRSA annotation, and IAM role permissions.

Costs
- EKS control plane and nodes, NAT Gateway, and external load balancers all incur costs. Destroy promptly if only experimenting.

Customization
- Node group size/types: `eks/eks.tf` under `eks_managed_node_groups`
- Kubernetes version and addons: `k8s_version` and `addons` in `eks/eks.tf`
- VPC and subnets: `eks/vpc.tf` (CIDR, subnets, AZs)
- Argo CD chart version/values: `eks/argocd.tf`
- ALB Controller version/values: `eks/alb_controller.tf`
- GitHub OIDC least privilege: prefer custom IAM policies and tightly scoped `github_oidc_subjects`

Key outputs
- `github_actions_role_arn`: IAM role for GitHub OIDC (store in GitHub Secrets)
- `github_oidc_provider_arn`: GitHub OIDC provider ARN
- `cluster_name`, `cluster_endpoint`, `cluster_ca_data`: EKS connection details
- `vpc_id`, `private_subnets`: Network component IDs
- `gha_principal_arn_in_eks`, `gha_access_policy_arn`: EKS access entry and associated policy

Paths & conventions
- Terraform working directory: `eks/`
- Variables template: `eks/terraform.tfvars.example`
- Do not commit personal `*.tfvars`; prefer `*.tfvars.example` for defaults
