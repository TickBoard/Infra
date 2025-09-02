variable "project" {
  description = "Project tag/name"
  type        = string
  default     = "sideproj-eks"
}

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

variable "k8s_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}
