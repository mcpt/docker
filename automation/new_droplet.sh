#!/usr/bin/env bash
set -e # Exit on error

SSH_KEYS=$(doctl compute ssh-key list --no-header --format ID)

doctl compute droplet create \
    --image ubuntu-24-04-x64 \
    --size s-1vcpu-1gb \
    --region tor1 \
    --enable-monitoring \
    --ssh-keys "$SSH_KEYS" \
    "$1"



#ansible-playbook -i inventory/new_droplet.yml playbooks/new_droplet.yml --extra-vars "droplet_name=$1"

