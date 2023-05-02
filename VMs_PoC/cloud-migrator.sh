#!/bin/bash
# Inspired by
# https://docs.fuga.cloud/migrate-an-instance-from-one-openstack-to-another
from_cloud="gx-scs"
to_cloud="beermann"
instance="instance-0"
snapshot="tmp"
original_cloud="${OS_CLOUD}"

export OS_CLOUD="${from_cloud}"
openstack server stop "${instance}"
openstack server image create "${instance}" --name "${snapshot}" --wait
format="$(openstack image show "${snapshot}" -f value -c disk_format)"
openstack image save --file "${snapshot}.${format}" "${instance}"
export OS_CLOUD="${to_cloud}"
openstack image create --progress --container-format bare --disk-format "${format}" --file "${snapshot}.${format}" "${snapshot}"
openstack server create \
    --flavor "SCS-2V-8-50" \
    --network "vanilla" \
    --security-group "all" \
    --image "${snapshot}" \
    --key-name "beermann" \
    "${instance}"
rm "${snapshot}.${format}"
export OS_CLOUD="${from_cloud}"
openstack server delete "${instance}"
export OS_CLOUD="${original_cloud}"
