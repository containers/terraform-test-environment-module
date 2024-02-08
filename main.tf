data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vpc-${var.environment}"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 0)
  private_subnets = ["10.0.0.0/16"]
  public_subnets  = ["10.0.101.0/16"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name              = "i-${var.environment}"
  availability_zone = element(module.vpc.azs, 0)
  subnet_id         = element(module.vpc.public_subnets, 0)
}
