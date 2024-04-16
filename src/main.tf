data "http" "my_ip" {
  url = "https://ipinfo.io/json"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "eks_module" {
  source = "./modules/eks_module"

  # EKS cluster
  cluster_name = var.cluster_name
  public_access_cidrs = ["${jsondecode(data.http.my_ip.response_body)["ip"]}/32"]
  node_group_instance_type = var.node_group_instance_type
  node_group_scaling_desired_size = var.node_group_scaling_desired_size
  node_group_scaling_max_size = var.node_group_scaling_max_size
  node_group_scaling_min_size = var.node_group_scaling_min_size
  node_group_name = var.node_group_name
  worker_node_key_name = var.worker_node_key_name

  # VPC
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  azs = var.azs
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  # Tags
  tags = var.tags
}
