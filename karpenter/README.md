# Karpenter Terraform Module

**Purpose:** Deploy and configure **Karpenter** to provide dynamic, on-demand node provisioning for an existing Amazon EKS cluster.

This module assumes the EKS cluster and its core infrastructure are already provisioned.

---

## What this module manages

- Karpenter controller deployment
- IAM roles and policies required for node provisioning
- IRSA configuration using the cluster OIDC provider
- Karpenter provisioners (node pools) and node templates
- Default settings for instance selection and capacity types

---
## Relationship to the EKS module

Responsibilities are intentionally split:

- **EKS module**
  - Control plane
  - IAM and OIDC
  - Cluster access
  - Minimal bootstrap node group

- **Karpenter module**
  - Node lifecycle and scaling
  - Instance selection and pricing strategy
  - Node labels, taints, and constraints

This separation keeps node provisioning logic isolated and easy to evolve.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.23 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.19.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0.1 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | >= 0.56.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.23 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 3.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.19.0 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | >= 0.56.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | 21.15.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.karpenter_nodes_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [tfe_outputs.cluster_acme](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/outputs) | data source |

## Inputs

No inputs.

## Outputs

No outputs.