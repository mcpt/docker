#!/usr/bin/env bash

set -e
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"

. ../dmoj/scripts/utils/notify
. ./swarm_info

echo "# DROPLET REMOVER 40000 :tm:"
echo "----------------------------------------------"
function select_droplet() {
    echo "Available Droplets:"
    # Retrieve Droplet names and IDs
    droplet_data=($(doctl compute droplet list --format "Name,ID"))
    sleep 1
    # Combine name and ID into display format
    options=()
    for (( i=0; i<${#droplet_data[@]}; i+=2 )); do
        options+=("${droplet_data[i]} (ID: ${droplet_data[i+1]})")
    done

    printf "%s\n" "${options[@]}"
    echo "eeep"

    select option in "${options[@]}" Exit; do
        if [[ "$option" == "Exit" ]]; then
            exit 0
        elif [[ -n "$option" ]]; then
            # Extract name and ID from selected option
            droplet_name=$(echo "$option" | cut -d' ' -f1)
            droplet_id=$(echo "${option/.*(ID: \([^)]*\)).*/\1/'}")
            echo "Selected: $droplet_name (ID: $droplet_id)"
            break
        else
            echo "Invalid selection."
        fi
    done
    echo "$droplet_name $droplet_id"  # Return both name and ID
}

droplet_name_and_id=($(select_droplet))  # Store both name and ID in an array
droplet_name=${droplet_name_and_id[0]}  # Extract the name
droplet_id=${droplet_name_and_id[1]}    # Extract the ID


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

read -r -p "Are you sure you want to delete Droplet \"$droplet_name?\" (y/n) " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deleting droplet $droplet_name..."
    notify "## Deleting Droplet: **$droplet_name**"
    doctl compute droplet delete "$droplet_id" -f
    notify "> Droplet **$droplet_name** is deleted!"
else
    echo "Deletion cancelled."
fi
