variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "eks-sideproj-admin"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "sideproj-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_amp_remote_write" {
  description = "是否啟用 Prometheus remote_write 到 AMP"
  type        = bool
  default     = false
}

variable "amp_workspace_id" {
  description = "Amazon Managed Prometheus Workspace 的 ID"
  type        = string
  default     = "ws-7342f032-c59b-4d63-af2a-3490e173eb7a"
}

variable "kps_version" {
  type    = string
  default = "65.3.1"
}

variable "loki_stack_version" {
  description = "Grafana loki-stack chart version"
  type        = string
}

variable "external_secrets_version" {
  description = "external-secrets/external-secrets chart version"
  type        = string
}
