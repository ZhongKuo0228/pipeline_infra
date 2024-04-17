# EC2 Config

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_name_pattern" {
  description = "Pattern to match the AMI name"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ami_virtualization_type" {
  description = "Virtualization type of the AMI"
  type        = string
  default     = "hvm"
}

variable "ami_owners" {
  description = "List of owners for the AMI"
  type        = list(string)
  default     = ["099720109477"] # Canonical 的 AWS 帳號 ID
}


variable "ec2_iam_role" {
  description = "EC2 iam role"
  type        = string
  default     = "reader"
}
