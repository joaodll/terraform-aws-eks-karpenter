data "tfe_outputs" "cluster_acme" {
  organization = "ACME"
  workspace    = "eks-acme"
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}

locals {
  cluster_endpoint = data.tfe_outputs.cluster_acme.values.cluster_endpoint
  cluster_name     = data.tfe_outputs.cluster_acme.values.cluster_name
  region           = "us-east-1"

  kapenter_files = {
    system_pods_pool  = "${path.module}/nodes/system_pods_pool.yaml.tpl"
    system_pods_class = "${path.module}/nodes/system_pods_class.yaml.tpl"
  }

  tags = {
    Project = "ACME"
    Module  = "Karpenter"
  }
}
