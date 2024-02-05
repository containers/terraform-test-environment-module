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
