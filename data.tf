data "aws_vpc" "vpc" {
  filter {
    name   = "tag:EKS_VPC"
    values = ["true"]
  }
}

data "aws_subnets" "pvt_eks_subnets" {
  tags = {
    Subnet_type = "private"
    EKS_VPC     = "true"
  }
}


locals {
  region              = "us-east-1"
  karpenter_node_name = "eks-karpenter-pods"
  cluster_name        = "my-acme-cluster"

  tags = {
    Project = "ACME"
  }
}