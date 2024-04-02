locals {
  pem_filename = basename(local_sensitive_file.private_key.filename)
}

output "host" {
  value = "${module.ec2-instance.public_dns}"
}

output "key_path" {
  value = "${local.pem_filename}"
}

output "key" {
  value     = "${module.key_pair.private_key_openssh}"
  sensitive = true
}
