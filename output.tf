locals {
  pem_filename = basename(local_sensitive_file.private_key.filename)
}

output "id" {
  value = "${module.ec2-instance.id}"
}
