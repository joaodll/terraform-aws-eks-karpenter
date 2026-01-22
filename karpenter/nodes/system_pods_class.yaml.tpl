apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: ${system_node_name}
spec:
  amiFamily: Bottlerocket
  role: ${node_iam_role_name}
  amiSelectorTerms:
    - id: ${ami_id}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${cluster_name}
        kubernetes.io/role/internal-elb: "1"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${cluster_name}
  tags:
    karpenter.sh/discovery: ${cluster_name}
    ManagedBy: karpenter
    Workload: ${system_node_name}
