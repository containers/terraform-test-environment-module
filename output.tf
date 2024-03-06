output "ssh_connect" {
  value = "ssh -X -i ${local_sensitive_file.private_key.filename} fedora@${module.ec2-instance.public_dns}"
}
