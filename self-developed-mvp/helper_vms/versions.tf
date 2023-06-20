terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  cloud = var.source_cloud
  alias = "source"
}

provider "openstack" {
  cloud = var.destination_cloud
  alias = "destination"
}
