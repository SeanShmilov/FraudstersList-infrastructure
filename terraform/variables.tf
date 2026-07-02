variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "fifaapp-eks"
}

variable "cluster_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 Instance type for EKS nodes"
  type        = string
  default     = "t3.micro"
}

variable "desired_nodes" {
  description = "Desired number of nodes in EKS"
  type        = number
  default     = 16
}

variable "tfc_organization" {
  description = "Terraform Cloud Organization"
  type        = string
  default     = ""
}

variable "tfc_workspace" {
  description = "Terraform Cloud Workspace"
  type        = string
  default     = "fifaapp-eks"
}
