data "aws_availability_zones" "available" {}

data "aws_ami" "fedora" {
  most_recent = true
  owners      = ["125523088429"]

  filter {
    name   = "name"
    values = ["Fedora-Cloud-Base-*"]
  }

  filter {
    name   = "platform"
    values = ["Fedora"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "region"
    values = [var.aws_region]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vpc-${var.environment}"
  cidr = "10.0.0.0/16"

  azs            = slice(data.aws_availability_zones.available.names, 0, 1)
  public_subnets = ["10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name              = "i-${var.environment}"
  availability_zone = module.vpc.azs[0]
  subnet_id         = module.vpc.public_subnets[0]
  ami               = data.aws_ami.fedora.id
}
