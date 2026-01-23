# EKS with Karpenter — Architecture & Design

**Purpose:** Provision an Amazon EKS cluster designed for dynamic, cost-efficient capacity using **Karpenter**, while keeping a minimal managed node group to bootstrap the cluster and Karpenter itself.

---

## Architecture at a glance

- **EKS control plane** and core AWS resources managed in this Terraform module
- **Karpenter deployed as a separate Terraform module**, consuming cluster outputs
- **Bottlerocket** used as the operating system
- **Minimal managed node group** to solve the Karpenter bootstrap (chicken-and-egg) problem
- **EKS Access Entries** used for IAM-based cluster access
- **Karpenter node pools** can be targeted using taints/tolerations (addons included as an example)

---

## Karpenter as a separate module

Karpenter is intentionally deployed outside of the core EKS module.

**Why:**
- Clear separation between cluster lifecycle and node provisioning
- Safer upgrades and experimentation with Karpenter
- Reduced blast radius when changing scaling or instance-selection logic

This module exposes only the required outputs (cluster name, endpoint, OIDC provider, IAM roles), which are consumed by the Karpenter module.

---

## Managed node group (bootstrap / chicken-and-egg)

Karpenter runs as a Kubernetes controller and depends on core system components being scheduled first (CoreDNS, VPC CNI, kube-proxy, and the Karpenter controller itself).

This creates a chicken-and-egg problem: **nodes are required before Karpenter can create nodes**.

### Design decision

A **very small managed node group** is created to:
- Bootstrap the cluster
- Run critical system pods
- Host the Karpenter controller

This node group:
- Is intentionally minimal (e.g. 1–2 on-demand nodes)
- Is not intended for application workloads
- Can be reduced or removed once Karpenter is stable (optional)

After bootstrap, **application capacity is expected to be provided by Karpenter**.

---

## Bottlerocket for Karpenter nodes

Karpenter provisions worker nodes using **Bottlerocket**, an AWS-maintained, container-optimized operating system.

**Benefits:**
- Minimal attack surface (no SSH, immutable filesystem)
- Predictable configuration and updates
- Well suited for ephemeral, replaceable nodes

This reinforces the idea that nodes are disposable infrastructure.

---

## Access management (EKS Access Entries)

Cluster access is managed using **EKS Access Entries**, replacing manual management of the `aws-auth` ConfigMap.

**Advantages:**
- Declarative and auditable access control in Terraform
- IAM-native authentication and authorization
- Easier to enforce least-privilege access

Access entries are defined for administrators and automation roles (e.g. CI/CD).

---

## Node pools, taints/tolerations (usage example)

Karpenter allows defining multiple provisioners (logical node pools) with different:
- Instance types
- Capacity types (On-Demand / Spot)
- Labels and taints

**Example usage:**
- Create a Karpenter provisioner for a specific workload class (e.g. `system`, `spot`, `high-memory`)
- Use **taints and tolerations** so selected workloads — including addons if desired — run only on those nodes

The addon tolerations referenced in this project are **an example of how to target Karpenter node pools**, not a strict requirement.

---

## Design principles

- **Immutable infrastructure**: nodes are replaceable
- **Separation of concerns**: cluster vs node lifecycle
- **Least privilege**: scoped IAM roles and access entries
- **Minimal static capacity**: bootstrap only; scale dynamically with Karpenter

---

## High-level flow

1. Deploy this EKS Terraform module  
   → cluster, IAM, OIDC, access entries, minimal managed node group

2. Deploy the Karpenter Terraform module  
   → controller, IAM roles, provisioners

3. Deploy workloads  
   → Karpenter provisions nodes dynamically based on demand

---


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 21.15.1 |
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | 6.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_subnets.pvt_eks_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Cluster Endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster Name |
| <a name="output_name"></a> [name](#output\_name) | The ARN of the OIDC Provider |