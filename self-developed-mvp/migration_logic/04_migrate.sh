#!/bin/bash
user=ubuntu
source_vm=$(terraform -chdir=helper_vms output -raw source_public_ip)
connection="${user}@${source_vm}"

# check if copy already finished
if ssh "${connection}" test -f /finished; then
    echo "copy finished"
else
    # check if copy session is not present and needs to be started
    if test -z "$(ssh "${connection}" screen -ls | grep copy)"; then
        echo "$(date "+%Y-%m-%d %H:%M:%S") copy started."
        ssh "${connection}" "screen -dmS copy bash -c 'sudo dd if=/dev/sdb bs=4M | pv | ssh 10.100.100.1 sudo dd of=/dev/sdb && sudo touch /finished'"
    fi
    
    # wait for copy to finish
    while ssh "${connection}" test ! -f /finished; do
        echo "$(date "+%Y-%m-%d %H:%M:%S") copy ongoing. you can safely cancel this script or wait for it to finish."
        sleep 10
    done
    echo "$(date "+%Y-%m-%d %H:%M:%S") copy finished."
fi
