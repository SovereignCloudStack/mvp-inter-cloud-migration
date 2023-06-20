terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "fip_pool" {}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.fip_pool
}

output "public_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}
