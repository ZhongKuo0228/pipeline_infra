# VPC

variable "vpc_name" {
  description = "The name of the VPC."
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
}

variable "azs" {
  description = "A list of availability zones."
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets."
  type        = list(string)
}

# EKS cluster 

variable "cluster_name" {
  type    = string
}

variable "public_access_cidrs" {
    description = "List of CIDR blocks"
    type = list(string)
}

variable "node_group_instance_type" {
  type = list(string)
}

variable "node_group_scaling_desired_size" {
  type = number
}

variable "node_group_scaling_max_size" {
  type = number
}

variable "node_group_scaling_min_size" {
  type = number
}

# Node Group

variable "node_group_name" {
  type    = string
}

variable "worker_node_key_name" {
  type = string
}

# CloudWatch
variable "retention_in_days" {
  type = number
  default = 3
}

# Tag
variable "tags" {
  type        = map(string)
  default     = {}
}
