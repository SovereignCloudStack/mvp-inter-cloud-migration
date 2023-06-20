#!/bin/bash
terraform -chdir=helper_vms init
terraform -chdir=helper_vms apply -var-file=../migrate.tfvars -auto-approve
#terraform -chdir=example_workload apply -auto-approve
bash migration_logic/00_wait.sh
ansible-playbook -i inventory.ini migration_logic/01_tunnel.yml
ansible-playbook -i inventory.ini migration_logic/02_ssh_keys.yml
ansible-playbook -i inventory.ini migration_logic/03_prepare_volumes.yml
bash migration_logic/04_migrate.sh
ansible-playbook -i inventory.ini migration_logic/05_cleanup_volumes.yml
#terraform -chdir=example_workload apply -destroy -auto-approve
#terraform -chdir=helper_vms apply -var-file=../migrate.tfvars -destroy -auto-approve
