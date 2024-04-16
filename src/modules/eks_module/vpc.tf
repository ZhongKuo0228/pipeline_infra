module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name             = var.vpc_name
  cidr             = var.vpc_cidr
  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  map_public_ip_on_launch = true

  # single NAT Gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # No public access to RDS instances
  create_database_subnet_group           = true
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false

   tags = {
    appworks = "SRE"
  }
}
