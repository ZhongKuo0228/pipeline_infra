output "cluster_endpoint" {
  value = module.eks_module.cluster_endpoint
}

output "bastion_ssh_command" {
  value = module.eks_module.bastion_ssh_command
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       =  module.eks_module.cluster_name
}