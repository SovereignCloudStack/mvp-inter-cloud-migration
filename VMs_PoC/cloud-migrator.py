#
# Cloud Migrator
#
# What does it do?  -> Migrate one VM from one OpenStack cloud to another
# What is required? -> Identical networks, flavors and security groups
#
# What should be added in the future probably?
#   -> Automatic floating IP assignments
#   -> Additional volume attachments
#   -> Seperate script for network and secgroup creation
#
# Inspired by
# https://docs.fuga.cloud/migrate-an-instance-from-one-openstack-to-another
###################################################################################################
# config dict in its final format
# {
#   "destination_cloud": <DESTINATION_OPENSTACK_CONFIG_OBJECT>,
#   "disk_format": "disk_format_string",
#   "flavor": "flavor_name_string",
#   "image": <IMAGE_OBJECT>,
#   "image_id": "image_id_string",
#   "instance": <SOURCE_INSTANCE_OBJECT>,
#   "instance_name": "instance_name_string",
#   "key_name": "key_name_string",
#   "md5_checksum": "md5_checksum_string",
#   "networks": ["network_name_a", "network_name_x"],
#   "security_groups": ["flavor_name_a", "flavor_name_x"],
#   "snapshot_name": "snapshot_name_string",
#   "source_cloud": <SOURCE_OPENSTACK_CONFIG_OBJECT>,
# }

import hashlib
import inquirer
import openstack
import openstack.config
import os
import time

from datetime import date
from loguru import logger


class CMConfig():
    destination_cloud: openstack.connection.Connection
    disk_format: str
    flavor: str
    image: openstack.cloud._image.ImageCloudMixin
    image_id: str
    instance: openstack.cloud._compute.ComputeCloudMixin
    instance_name: str
    key_name: str
    md5_checksum: str
    networks: list = []
    security_groups: list = []
    snapshot_name: str
    source_cloud: openstack.connection.Connection

    def __init__(self):
        # get global openstack config
        os_config = openstack.config.loader.OpenStackConfig()

        # get source and destination cloud objects
        cm_config = inquirer.prompt(
            [
                inquirer.List(
                    name="source_cloud",
                    message="Select the source cloud",
                    choices=os_config.get_cloud_names()
                ),
                inquirer.List(
                    name="destination_cloud",
                    message="Select the destination cloud",
                    choices=os_config.get_cloud_names()
                )
            ]
        )
        self.source_cloud = openstack.connect(cloud=cm_config['source_cloud'])
        self.destination_cloud = openstack.connect(cloud=cm_config['destination_cloud'])

        # prompt for matching instance name
        server_names = []
        for server in self.source_cloud.compute.servers():
            server_names.append(server.name)
        # get source instance name
        instance_name = inquirer.prompt(
            [
                inquirer.List(
                    name="instance",
                    message="Select the VM to migrate",
                    choices=server_names
                )
            ]
        )['instance']
        # fetch first matching instance object by name
        for server in self.source_cloud.compute.servers():
            if server.name == instance_name:
                self.instance = server
                self.instance_name = server.name
                self.key_name = server.key_name
                break

        # fetch flavor name
        self.flavor = self.instance.flavor['original_name']

        # fetch all networks
        for network in self.instance.addresses.keys():
            self.networks.append(network)

        # fetch all security groups
        for secgroup in self.instance.security_groups:
            self.security_groups.append(secgroup['name'])


def stop_source_vm(config: CMConfig) -> None:
    config.instance.stop()
    # check every 5 seconds if the instance is really stopped
    while config.instance.power_state != 4:
        time.sleep(5)


def create_source_vm_image(config: CMConfig) -> None:
    name = f"{str(date.today())}_{config.instance_name}"
    config.snapshot_name = name
    config.image_id = config.instance.create_image(name=name)
    return config


def get_source_vm_image_format(config: CMConfig) -> None:
    image = config.source_cloud.image.find_image(config.image_id)
    config.image = image
    config.disk_format = image.disk_format


def fetch_source_vm_image(config: CMConfig) -> None:
    # we have to use stream downloading, otherwise the whole
    # download will be put into ram
    # inspired by https://docs.openstack.org/openstacksdk/latest/user/guides/image.html#download-image-stream-true
    md5 = hashlib.md5()

    with open(f"{config.snapshot_name}.{config.disk_format}", "wb") as local_image:
        response = config.source_cloud.image.download_image(config.image, stream=True)

        # Read only 10MB of memory at a time until
        # all of the image data has been consumed.
        # 10485760 bytes = 10MB
        for chunk in response.iter_content(chunk_size=10485760):
            md5.update(chunk)
            local_image.write(chunk)

        if response.headers['Content-MD5'] != md5.hexdigest():
            raise Exception("Checksum mismatch in downloaded content")

    config.md5_checksum = md5.hexdigest()


def upload_image_to_destination(config: CMConfig) -> None:
    config.destination_cloud.image.create_image(
        config.snapshot_name,
        filename=f"{config.snapshot_name}.{config.disk_format}",
        md5=config.md5_checksum,
        disk_format=config.disk_format,
        container_format="bare",
        disable_vendor_agent=True,
        wait=True,
        timeout=86400,  # 24h
        allow_duplicates=False
    )


def create_destination_vm(config: CMConfig) -> None:
    config.destination_cloud.compute.create_server(
        config.instance_name,
        image=config.snapshot_name,
        flavor=config.flavor,
        auto_ip=True,
        terminate_volume=False,
        wait=True,
        timeout=300,  # 5 minutes
        reuse_ips=True,
        network=config.networks,
        boot_from_volume=False,
        # **kwargs
        key_name=config.key_name,
        security_groups=config.security_groups
    )


def remove_fetched_image(config: CMConfig) -> None:
    os.remove(f"{config.instance_name}.{config.disk_format}")


def remove_source_vm(config: CMConfig) -> None:
    config.instance.force_delete()


def main() -> None:
    config = CMConfig()
    logger.info("Stopping source VM")
    stop_source_vm(config)
    logger.success("Stopped source VM")
    logger.info("Creating source VM image")
    create_source_vm_image(config)
    logger.success("Created source VM image")
    get_source_vm_image_format(config)
    logger.info("Downloading source VM image")
    fetch_source_vm_image(config)
    logger.success("Downloaded source VM image")
    logger.info("Uploadimg image to destination")
    upload_image_to_destination(config)
    logger.success("Uploaded image to destination")
    logger.info("Creating destination VM")
    create_destination_vm(config)
    logger.success("Created destination VM")
    remove_fetched_image(config)
    logger.success("Deleted downloaded source VM image")
    remove_source_vm(config)
    logger.success("Removed source VM")


if __name__ == "__main__":
    main()
