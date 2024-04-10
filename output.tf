locals {
  pem_filename = basename(local_sensitive_file.private_key.filename)
}

output "id" {
  value = "${module.ec2-instance.id}"
}

output "host" {
  value = "${module.ec2-instance.public_dns}"
}

output "pem_filename" {
  value = "${pem_filename}"
}
