#!/bin/bash
user=ubuntu
source_ip=$(terraform -chdir=helper_vms output -raw source_public_ip)
destination_ip=$(terraform -chdir=helper_vms output -raw destination_public_ip)

ssh-keygen -R "${source_ip}"
until ssh -o StrictHostKeyChecking=accept-new "${user}@${source_ip}" exit; do
    sleep 5
done

ssh-keygen -R "${destination_ip}"
until ssh -o StrictHostKeyChecking=accept-new "${user}@${destination_ip}" exit; do
    sleep 5
done
