module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name                                     = local.cluster_name
  kubernetes_version                       = "1.34"
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access_cidrs             = [""] ### Some Public CIDR IP

  vpc_id      = data.aws_vpc.vpc.id
  subnet_ids  = data.aws_subnets.pvt_eks_subnets.ids
  enable_irsa = true

  access_entries = {
    administrator = {
      kubernetes_groups = ["Admin"]
      principal_arn     = "" ### The Role ARN of some AWS Users or Permission Set
      policy_associations = {
        administrator = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    karpenter = {
      name                = local.karpenter_node_name
      ami_type            = "BOTTLEROCKET_ARM_64"
      ami_release_version = "1.52.0-b7ac6e1a"
      instance_types      = ["t4g.small"]

      min_size      = 1
      desired_size  = 1
      max_size      = 2
      capacity_type = "ON_DEMAND"

      labels = {
        "karpenter.sh/controller" = true
        role                      = "on_demand"
        node_group                = local.karpenter_node_name
      }

      block_device_mappings = {
        xvdb = {
          device_name = "/dev/xvdb"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            volume_size           = 20
            volume_type           = "gp3"
          }
        }
      }
      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }
  node_security_group_tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.cluster_name
  })

  addons = {
    coredns = {
      addon_version               = "v1.12.4-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        replicaCount = 1
        tolerations = [{
          key      = "workload"
          operator = "Equal"
          value    = "system-pods"
          effect   = "NoSchedule"
        }]
        nodeSelector = {
          workload-type = "system-pods"
        }
      })
    }
    kube-proxy = {
      addon_version = "v1.34.1-eksbuild.2"
    }
    vpc-cni = {
      addon_version            = "v1.21.1-eksbuild.1"
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.arn
    }
    eks-pod-identity-agent = {
      addon_version  = "v1.3.10-eksbuild.1"
      before_compute = true
    }
    metric-server = {
      addon_version = "v1.3.10-eksbuild.1"
      configuration_values = jsonencode({
        replicaCount = 1
        tolerations = [{
          key      = "workload"
          operator = "Equal"
          value    = "system-pods"
          effect   = "NoSchedule"
        }]
        nodeSelector = {
          workload-type = "system-pods"
        }
      })
    }
  }
  tags = local.tags
}