# How-To

Migrate a VM from cloud A to cloud Z.

## Usage

1. alter the `migrate.tfvars` file according to your requirements
2. run `migrate.sh`
3. profit!

For testing purposes, you might want to deploy the _example_workload_ VM, this creates
a VM with an nginx webserver showing the text __FOOBAR__.

## Technical procedure

1. Helper-VMs get created inside both clouds
2. A wireguard tunnel between the helper VMs is established
3. The source VM will be stopped
4. An Image of this VM will be created
5. A Volume of this Image will be created
6. The Volume gets attached to the helper VM
7. An equally sized Volume is created in the destination cloud
8. The destination Volume gets attached to the second helper VM
9. Migration is now done via `dd` over `ssh` in a `screen` session to allow disconnect of client devices during the migration time
10. Both Volumes are detached from the helper VMs
11. Volume and Image in the source cloud are deleted
12. Destination Volume is made bootable
13. A new VM in the destination cloud is created that boots from the new volume
14. The source VM is deleted

## Manual steps required / limitations

- Destination Networks and Security Groups need to be created in advance
- Floating IPs are not released once the source has been removed
- Failures during e.g. Volume or Image creation need to be cleaned manually before retrying
- This scripts expects the remote user to be "ubuntu"

## Requriements

- Ansible
- OpenStack command line tools
- Terraform
- ed25519 ssh keys
