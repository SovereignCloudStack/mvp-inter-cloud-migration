output "public_ip" {
  value = openstack_compute_floatingip_associate_v2.fip.floating_ip
}
