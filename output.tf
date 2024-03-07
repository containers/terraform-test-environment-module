locals {
  pem_filename = basename(local_sensitive_file.private_key.filename)
}

output "ssh_connect" {
  value = "ssh -i ${local.pem_filename} fedora@${module.ec2-instance.public_dns}"
}
