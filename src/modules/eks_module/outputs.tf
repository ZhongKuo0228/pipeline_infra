output "cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "bastion_ssh_command" {
  value = "ssh -i ~/.ssh/${var.worker_node_key_name} ubuntu@${aws_instance.bastion.public_ip}"
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       =  aws_eks_cluster.eks-cluster.name
}