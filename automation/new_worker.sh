#!/usr/bin/env bash
set -e # Exit on error
cd "$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)"

[ "$(whoami)" = root ] || {
  sudo "$0" "$@"
  exit $?
} # enforce root as the ansible ssh key is installed under root

# grab a argument of --size
if [[ $* == *--large* ]]; then
  SIZE="s-2vcpu-2gb"
else
  SIZE="s-1vcpu-1gb"
fi

. ../dmoj/scripts/utils/notify
. ./swarm_info

if [ -z "$1" ]; then
  echo "Usage: $0 <droplet_name> [--large]"
  exit 1
fi

# Check if the droplet already exists as a safety measure
if doctl compute droplet list --format Name | grep -i "$1"; then
  echo "Droplet $1 already exists!" >&2
  exit 1
fi

SSH_KEYS=$(doctl compute ssh-key list --no-header --format ID)

echo "Provisioning new droplet $1..."
echo "SSH keys: $(doctl compute ssh-key list --no-header --format Name | tr '\n' ', ')"
echo "Creating droplet..."
notify "## Provisioning new droplet **$1**"

# Create the droplet
droplet_id=$(doctl compute droplet create \
  --image ubuntu-22-04-x64 \
  --size "$SIZE" \
  --region tor1 \
  --enable-monitoring \
  --tag-names "worker" \
  --ssh-keys "$SSH_KEYS" \
  "$1" --output json | jq -r '.[0].id')

# Wait for the droplet to be active
echo "Waiting for droplet to be active..."
while true; do
  status=$(doctl compute droplet get "$droplet_id" --output json | jq -r '.[0].status')
  if [ "$status" = "active" ]; then
    break
  fi
  sleep 2
done

# Get the public and private IP addresses, guaranteed to be at index zero as we limit names
droplet_pub_ipv4=$(doctl compute droplet get "$droplet_id" --output json | jq -r '.[0].networks.v4[] | select(.type == "public") | .ip_address')
droplet_priv_ipv4=$(doctl compute droplet get "$droplet_id" --output json | jq -r '.[0].networks.v4[] | select(.type == "private") | .ip_address')

echo "Droplet is active!, public IP: $droplet_pub_ipv4, private IP: $droplet_priv_ipv4"
notify "> Droplet **$1** is active at __ $droplet_pub_ipv4 __"
# Wait for SSH to become available
echo "Waiting for SSH to be available..."
while ! ssh -o StrictHostKeyChecking=no -q root@"$droplet_priv_ipv4" exit; do
  sleep 5
done

echo "SSH is available!"

# Run the Ansible playbook once SSH is up
echo "Running Ansible playbook..."
update_inventory
ansible-playbook -i ./inventory.ini ./playbooks/initialize_worker.yml --extra-vars "droplet_name=$1 ansible_host=$droplet_priv_ipv4 public_ipv4=$droplet_pub_ipv4 ansible_user=root"

notify "Droplet ***$1*** is provisioned and configured!"
echo "**Droplet $1 is provisioned and configured!**"
