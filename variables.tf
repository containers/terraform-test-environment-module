variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "aws_profile" {
  description = "AWS profile."
  type        = string
  default     = "default"
}

variable "environment" {
  description = "One of the following environments: dev, prod"
  type        = string
  default     = "dev"
}

variable "ssh_private_key_filename" {
  description = "SSH private key file name"
  type        = string
  default     = "dev.pem"
}

variable "root_directory" {
  description = "Directory where the private key file is saved"
  type        = string
  default     = "."
}

variable "aws_ami_owners" {
  description = "AWS AMI Owners"
  type        = list(string)
}

variable "aws_ami_name" {
  description = "AWS AMI name"
  type        = list(string)
}

variable "aws_instance_type" {
  description = "AWS Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "aws_volume_size" {
  description = "AWS EC2 root block device volume size"
  type        = number
  default     = 10
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "provision_script" {
  description = "Provision script key"
  type        = string
}
