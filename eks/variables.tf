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
  default     = "root"
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

variable "kms_key_arn" {
  type        = string
  description = "Existing KMS key ARN for EKS secret encryption"
  default     = "arn:aws:kms:ap-southeast-2:512160136658:key/a8f9ca4f-a478-4aac-b682-b9ac23647c2a"
}