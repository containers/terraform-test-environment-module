locals {
  pem_filename = basename(local_sensitive_file.private_key.filename)
}

output "id" {
  value = "${module.ec2-instance.id}"
}

output "host" {
  value = "${module.ec2-instance.public_dns}"
}

output "ssh_public_key" {
  value = "${module.key_pair.public_key_openssh}"
}

output "pem_filename" {
  value = "${local.pem_filename}"
}
