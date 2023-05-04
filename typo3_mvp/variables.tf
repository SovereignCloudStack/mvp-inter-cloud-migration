variable "name" {}
variable "description" {
  default = ""
}
variable "fip_pool" {}
variable "ssh_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}
variable "image_name" {
  default = "Ubuntu 22.04"
}
variable "flavor_name" {
  default = "SCS-2V-4-10"
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
