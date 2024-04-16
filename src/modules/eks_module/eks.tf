data "http" "my_ip" {
  url = "https://ipinfo.io/json"
}

# eks cluster
resource "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets 
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs = ["${jsondecode(data.http.my_ip.response_body)["ip"]}/32"]
  }

  enabled_cluster_log_types = ["api", "audit"]

  depends_on = [ 
    aws_iam_role.eks-iam-role,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-EKS,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.task4-cloudwatch-logs
]

  tags = var.tags
}

# worker node
resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.eks-cluster.name
  node_group_name = var.node_group_name
  node_role_arn  = aws_iam_role.workernodes-iam-role.arn
  subnet_ids   = module.vpc.private_subnets
  instance_types = var.node_group_instance_type

  scaling_config {
    desired_size = var.node_group_scaling_desired_size
    max_size   = var.node_group_scaling_max_size
    min_size   = var.node_group_scaling_min_size
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.generated_key.key_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonS3ReadOnlyAccess,
    aws_iam_role_policy_attachment.CloudWatchReadOnlyAccess
  ]

  tags = var.tags
}

# gen ssh key
resource "tls_private_key" "terraform_generated_key_worker_node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# save ssh private key under local .ssh directory
resource "local_sensitive_file" "private_key_worker_node" {
  content  = tls_private_key.terraform_generated_key_worker_node.private_key_pem
  filename = pathexpand("~/.ssh/${var.worker_node_key_name}")
  file_permission = 400
}

# attach key on newly created worker_node
resource "aws_key_pair" "generated_key" {
  key_name   = var.worker_node_key_name
  public_key = tls_private_key.terraform_generated_key_worker_node.public_key_openssh

  tags = var.tags
}

# cloudwatch log
resource "aws_cloudwatch_log_group" "task4-cloudwatch-logs" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.retention_in_days

  tags = var.tags
}

# bastion ec2
resource "aws_security_group" "allow_ssh" {
  vpc_id = module.vpc.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  subnet_id = module.vpc.public_subnets[0]
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.allow_ssh.id]

  tags = merge(var.tags, {
    Name: "bastion"
  })
}


