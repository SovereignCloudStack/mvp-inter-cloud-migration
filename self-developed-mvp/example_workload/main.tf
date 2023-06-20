terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  cloud = "scs-community-generic"
}

variable "name" {
  default = "example-workload"
}

variable "fip_pool" {
  default = "ext01"
}

variable "network_name" {
  default = "migration_source_vm"
}

variable "ssh_key_path" {
  default  = "~/.ssh/id_ed25519.pub"
  nullable = false
}

variable "image_name" {
  default  = "Ubuntu 22.04"
  nullable = false
}

variable "flavor_name" {
  default  = "SCS-2V:4:10"
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
    },
    {
      "from_port" = 80
      "to_port"   = 80
    },
    {
      "ethertype" = "IPv6"
      "from_port" = 80
      "to_port"   = 80
      "cidr"      = "::/0"
    }
  ]
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.fip_pool
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.name
  public_key = file(pathexpand(var.ssh_key_path))
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name = var.name
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
    - nginx
  write_files:
  - content: |
      <h1>FOOBAR</h1>
    path: /var/www/html/index.html
  EOT

  network {
    name = var.network_name
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.instance.id
}

output "public_ip" {
  value = openstack_compute_floatingip_associate_v2.fip.floating_ip
}
