apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ${system_node_name}
spec:
  template:
    metadata:
      labels:
        workload-type: system-pods
        node-type: ${system_node_name}
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: ${system_node_name}
      requirements:
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["on-demand", "spot"]
        - key: node.karpenter.io/instance-instance-type"
          operator: In
          values:
            - t4g.small
            - t4g.medium
        - key: "karpenter.io/arch"
          operator: In
          values: ["arm64"]
      taints:
        - key: "workload"
          value: ${system_node_name}
          effect: "NoSchedule"
  limits:
    cpu: "6"
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
    expiredAfter: 160h
