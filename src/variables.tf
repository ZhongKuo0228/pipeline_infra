# Region

variable "region" {
  description = "The AWS region to deploy the VPC in."
  default     = "ap-northeast-1"
}

# VPC

variable "vpc_name" {
  description = "The name of the VPC."
  default     = "task-6-1-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones."
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "public_subnets" {
  description = "A list of public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_subnets" {
  description = "A list of private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24","10.0.102.0/24"]
}

# EKS cluster 

variable "cluster_name" {
  type    = string
  default     = "task-6-1-eks"
}

variable "node_group_instance_type" {
  type = list(string)
  default = ["t3.small"]
}

variable "node_group_scaling_desired_size" {
  type = number
  default = 1
}

variable "node_group_scaling_max_size" {
  type = number
  default = 3
}

variable "node_group_scaling_min_size" {
  type = number
  default = 1
}

# Node Group

variable "node_group_name" {
  type    = string
  default = "task-6-1-workernodes-group"
}

variable "worker_node_key_name" {
  type = string
  default = "hw_sshkey"
}

# CloudWatch
variable "retention_in_days" {
  type = number
  default = 3
}

# Tag
variable "tags" {
  type        = map(string)
  default     = {
    "appworks" : "SRE"
  }
}