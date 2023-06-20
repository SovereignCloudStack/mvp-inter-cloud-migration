output "source_public_ip" {
  value = module.source_fip.public_ip
}

output "destination_public_ip" {
  value = module.destination_fip.public_ip
}
