module "source_fip" {
  source = "./modules/floating_ip"

  providers = {
    openstack = openstack.source
  }

  fip_pool = var.source_fip_pool
}

module "destination_fip" {
  source = "./modules/floating_ip"

  providers = {
    openstack = openstack.destination
  }

  fip_pool = var.destination_fip_pool
}

module "source_vm" {
  source = "./modules/vm"

  providers = {
    openstack = openstack.source
  }

  name            = "migration_source_vm"
  fip_pool        = var.source_fip_pool
  fip_address     = module.source_fip.public_ip
  flavor_name     = var.source_flavor_name
  image_name      = var.source_image_name
  ssh_key_path    = var.ssh_key_path
  pair_vm_address = module.destination_fip.public_ip
}

module "destination_vm" {
  source = "./modules/vm"

  providers = {
    openstack = openstack.destination
  }

  name            = "migration_destination_vm"
  fip_pool        = var.destination_fip_pool
  fip_address     = module.destination_fip.public_ip
  flavor_name     = var.destination_flavor_name
  image_name      = var.destination_image_name
  ssh_key_path    = var.ssh_key_path
  pair_vm_address = module.source_fip.public_ip
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.ini.tftpl",
    {
      source_public_ip            = module.source_fip.public_ip
      destination_public_ip       = module.destination_fip.public_ip
      source_cloud                = var.source_cloud
      destination_cloud           = var.destination_cloud
      source_helper_vm            = module.source_vm.name
      destination_helper_vm       = module.destination_vm.name
      instance_name               = var.name_of_instance_to_migrate
      volume_size                 = var.root_volume_size_of_instance
      destination_flavor          = var.destination_flavor
      destination_network         = var.destination_network
      destination_security_groups = var.destination_security_groups
    }
  )
  filename = "../inventory.ini"
}
