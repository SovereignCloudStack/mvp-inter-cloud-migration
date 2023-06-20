source_cloud       = "regiocloud"    # name of the cloud in your clouds.yml
source_fip_pool    = "public"        # name of the floating ip pool
source_flavor_name = "SCS-2V-4-10"   # name of the flavor for the helper VM
source_image_name  = "Ubuntu 22.04"  # name of the image for the helper VM, needs to be an Ubuntu based distribution

destination_cloud       = "scs-community-generic"  # name of the cloud in your clouds.yml
destination_fip_pool    = "ext01"                  # name of the floating ip pool
destination_flavor_name = "SCS-2V:4:10"            # name of the flavor for the helper VM
destination_image_name  = "Ubuntu 22.04"           # name of the image for the helper VM, needs to be an Ubuntu based distribution

name_of_instance_to_migrate  = "example-workload"         # name of the VM, can also be UUID
root_volume_size_of_instance = 10                         # size of the source flavor root disk in GB
destination_flavor           = "SCS-2V:4:10"              # name of the flavor in the destination cloud
destination_network          = "p500924-generic-network"  # name of the destination network
destination_security_groups  = "[\"all\"]"                # string that holds a list of destination security groups
