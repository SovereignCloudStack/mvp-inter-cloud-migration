name        = "mvp-typo3"
description = "@alexander-diab's and @tibeer's mvp for typo3"
fip_pool    = "ext01"
flavor_name = "SCS-2V:4:10"
secgroup_rules = [
  {
    "from_port" = 22
    "to_port"   = 22
  },
  {
    "from_port" = 80
    "to_port"   = 80
  },
  {
    "from_port" = 443
    "to_port"   = 443
  },
  {
    "ethertype" = "IPv6"
    "from_port" = 22
    "to_port"   = 22
    "cidr"      = "::/0"
  },
  {
    "ethertype" = "IPv6"
    "from_port" = 80
    "to_port"   = 80
    "cidr"      = "::/0"
  },
  {
    "ethertype" = "IPv6"
    "from_port" = 443
    "to_port"   = 443
    "cidr"      = "::/0"
  }
]