variable "source_cloud" {
  default = "source"
}

variable "source_fip_pool" {
  default = "public"
}

variable "source_flavor_name" {
  default = null
}

variable "source_image_name" {
  default = null
}

variable "destination_cloud" {
  default = "destination"
}

variable "destination_fip_pool" {
  default = "public"
}

variable "destination_flavor_name" {
  default = null
}

variable "destination_image_name" {
  default = null
}

variable "ssh_key_path" {
  default = null
}

variable "name_of_instance_to_migrate" {}
variable "root_volume_size_of_instance" {}
variable "destination_flavor" {}
variable "destination_network" {}
variable "destination_security_groups" {}
