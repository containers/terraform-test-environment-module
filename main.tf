data "aws_availability_zones" "available" {}

data "aws_ami" "ami" {
  most_recent = true
  owners      = var.aws_ami_owners

  filter {
    name   = "name"
    values = var.aws_ami_name
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"
  vars = {
    aws_cache_bucket = "${var.aws_cache_bucket}"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.6.0"

  name = var.environment
  cidr = "10.0.0.0/16"

  azs            = slice(data.aws_availability_zones.available.names, 0, 1)
  public_subnets = ["10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.3"

  key_name           = var.environment
  create_private_key = true
}

resource "local_sensitive_file" "private_key" {
  content         = "${module.key_pair.private_key_openssh}\n"
  filename        = "${var.root_directory}/${var.ssh_private_key_filename}"
  file_permission = 0400
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = var.environment
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "consul-webui-https-tcp", ]
  egress_rules        = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8001
      to_port     = 8001
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

data "aws_iam_policy_document" "assume_role_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "instance_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_document.json
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.instance_role.name
}

data "aws_iam_policy_document" "instance_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.aws_cache_bucket}",
      "arn:aws:s3:::${var.aws_cache_bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "instance_policy" {
  name   = "instance-policy"
  policy = data.aws_iam_policy_document.instance_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name                        = var.environment
  availability_zone           = module.vpc.azs[0]
  subnet_id                   = module.vpc.public_subnets[0]
  ami                         = data.aws_ami.ami.id
  associate_public_ip_address = true
  key_name                    = module.key_pair.key_pair_name
  vpc_security_group_ids      = [module.security_group.security_group_id]
  user_data                   = data.template_file.user_data.rendered
  instance_type               = var.aws_instance_type
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  root_block_device = [
    {
      volume_size = var.aws_volume_size
    }
  ]
}
