#!/usr/bin/env bash

set -e
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"

. ../dmoj/scripts/utils/notify
. ./swarm_info


function select_droplet() {
    echo "Available Droplets:"
    droplets=($(doctl compute droplet list --format Name))
    select droplet in "${droplets[@]}" Exit; do
        if [[ "$droplet" == "Exit" ]]; then
            exit 0
        elif [[ -n "$droplet" ]]; then
            echo "Selected: $droplet"
            break
        else
            echo "Invalid selection."
        fi
    done
    echo "$droplet"
}

droplet_name=$(select_droplet)

if ! doctl compute droplet list --format Name | grep -q "$droplet_name"; then
    echo "Droplet $droplet_name does not exist!" >&2
    exit 1
fi

droplet_id=$(doctl compute droplet list --no-header --format ID --filter "name=$droplet_name")
echo "ID of the Droplet is: $droplet_id"

# Force removal flag (default is false)
force_removal=false

# Check for arguments and set force_removal if --force is provided
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force | -f)
      force_removal=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if docker node ls | grep -q "$droplet_name"; then
    echo "Warning: Droplet $droplet_name is part of the Swarm cluster."

    if $force_removal; then
        echo "Forcing removal of node $droplet_name from Swarm..."
        docker node rm -f "$droplet_name"
    else
            echo "Draining node $droplet_name from Swarm..."
            docker node update --availability drain "$droplet_name"
            while docker node ls | grep -q "$droplet_name"; do
                echo "Waiting for node to drain..."
                sleep 5
            done
            echo "Removing node $droplet_name from Swarm..."
            notify "## Removing Node: **$droplet_name** from Swarm"
            docker node rm "$droplet_name"
    fi
fi

read -r -p "Are you sure you want to delete Droplet '$droplet_name'? (y/n) " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deleting droplet $droplet_name..."
    notify "## Deleting Droplet: **$droplet_name**"
    doctl compute droplet delete "$droplet_id" -f
    notify "> Droplet **$droplet_name** is deleted!"
else
    echo "Deletion cancelled."
fi
