terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

variable "name" {}

variable "fip_pool" {}

variable "fip_address" {}

variable "pair_vm_address" {}

variable "ssh_key_path" {
  default  = "~/.ssh/id_ed25519.pub"
  nullable = false
}

variable "image_name" {
  default  = "Ubuntu 22.04"
  nullable = false
}

variable "flavor_name" {
  default  = "SCS-2V-4-10"
  nullable = false
}

variable "secgroup_rules" {
  type = list(map(any))
  default = [
    {
      "from_port" = 22
      "to_port"   = 22
    },
    {
      "ethertype" = "IPv6"
      "from_port" = 22
      "to_port"   = 22
      "cidr"      = "::/0"
    }
  ]
}

variable "network_cidr" {
  default = "192.168.42.0/24"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.name
  public_key = file(pathexpand(var.ssh_key_path))
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = var.name
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule" {
  count = length(var.secgroup_rules)

  direction         = lookup(element(var.secgroup_rules[*], count.index), "direction", "") != "" ? var.secgroup_rules[count.index].direction : "ingress"
  ethertype         = lookup(element(var.secgroup_rules[*], count.index), "ethertype", "") != "" ? var.secgroup_rules[count.index].ethertype : "IPv4"
  protocol          = lookup(element(var.secgroup_rules[*], count.index), "ip_protocol", "") != "" ? var.secgroup_rules[count.index].ip_protocol : "tcp"
  port_range_min    = element(var.secgroup_rules[*].from_port, count.index)
  port_range_max    = element(var.secgroup_rules[*].to_port, count.index)
  remote_ip_prefix  = lookup(element(var.secgroup_rules[*], count.index), "cidr", "") != "" ? var.secgroup_rules[count.index].cidr : "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_network_v2" "network" {
  name           = var.name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  network_id = openstack_networking_network_v2.network.id
  cidr       = var.network_cidr
  ip_version = 4
}

data "openstack_networking_network_v2" "extnet" {
  name = var.fip_pool
}

resource "openstack_networking_router_v2" "router" {
  name                = var.name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.extnet.id
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_compute_instance_v2" "instance" {
  name            = var.name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.keypair.name
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]
  user_data       = <<-EOT
  #cloud-config
  package_update: true
  packages:
  - pv
  - screen
  write_files:
  - content: |
      ${var.pair_vm_address}
    path: /root/pair_vm_address
  EOT

  network {
    uuid = openstack_networking_subnet_v2.subnet.network_id
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = var.fip_address
  instance_id = openstack_compute_instance_v2.instance.id
}

output "public_ip" {
  value = openstack_compute_floatingip_associate_v2.fip.floating_ip
}

output "name" {
  value = openstack_compute_instance_v2.instance.name
}
