module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.15.1"

  cluster_name = local.cluster_name

  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = "karpenter-node-${local.cluster_name}"
  create_pod_identity_association = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.8.3"
  wait       = false
  atomic     = true

  values = [
    templatefile("${path.module}/values/karpenter.yaml.tpl", {
      cluster_name     = local.cluster_name
      queue_name       = module.karpenter.queue_name
      cluster_endpoint = local.cluster_endpoint
      service_account  = module.karpenter.service_account
    })
  ]
}

resource "kubectl_manifest" "karpenter_nodes_config" {
  for_each = local.kapenter_files

  yaml_body = templatefile(each.value, {
    node_iam_role_name = module.karpenter.node_iam_role_name
    cluster_name       = local.cluster_name
    ami_id             = "<some_bottlerocket_ami_id>"
    system_node_name   = "system-pods"
  })
}
