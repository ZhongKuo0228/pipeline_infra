# 使用 aws 的 provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 使用 aws 的 provider 並設定 Region

provider "aws" {
  region = var.aws_region
}

# 建立的 VPC 與相關網路設定

resource "aws_vpc" "ec2" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "task-6-1"
  }
}


resource "aws_subnet" "ec2" {
  vpc_id                  = aws_vpc.ec2.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "task-6-1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2.id

  tags = {
    Name = "igw-task-6-1"
  }
}

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.ec2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rtable-task-1-2"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.ec2.id
  route_table_id = aws_route_table.rtable.id
}

# 建立可以使用 SSH 連線的 Security Group

resource "aws_security_group" "only_for_ssh" {
  name        = "only-for-ssh"
  description = "Security group for SSH access"
  vpc_id      = aws_vpc.ec2.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "only-for-ssh"
  }
}

# 選擇公版的 AMI 來建立 EC2

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }

  owners = var.ami_owners
}

# 選擇與 EC2 連線的 ssh key

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/terraform-ssh-key.pub")
}

# 建立 EC2 的 instance 與設定 instance 建立後要執行的工作

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.ec2.id
  iam_instance_profile   = var.ec2_iam_role
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.only_for_ssh.id]

  tags = {
    Name = "task-6-1"
  }
}

# 確認 instance 建立後要執行的工作是否完成

resource "null_resource" "wait_for_cloud_init" {
  depends_on = [aws_instance.ec2]

  connection {
    type        = "ssh"
    host        = aws_instance.ec2.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/terraform-ssh-key")
  }
}

# 等 Terraform 完成 EC2 的全部工作後，會輸出新建 EC2 的 Public IP

output "INSTANCE_IP" {
  value = aws_instance.ec2.public_ip
}

output "INSTANCE_ID" {
  value = aws_instance.ec2.id
}
