locals {
  karpenter_node_name = "eks-karpenter-pods"
  cluster_name        = "my-acme-cluster"
  tags = {
    Project = "ACME"
  }
}