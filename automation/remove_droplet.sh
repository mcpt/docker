#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

if [ "$HOSTNAME" != "general" ]; then
  echo "Please run on general"
  exit
fi

set -e
cd "$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)"

. ../dmoj/scripts/utils/notify
. ./swarm_info

echo "# DROPLET REMOVER 40000 :tm:"
echo "----------------------------------------------"
echo "Available Droplets:"

function select_droplet() {
  options=()
  while read -r line; do
    name=$(echo "$line" | awk '{print $1}')
    id=$(echo "$line" | awk '{print $2}')
    options+=("$name (ID: $id)")
  done < <(doctl compute droplet list --format "Name,ID" --no-header)

  PS3="Choose an entry: "
  COLUMNS=12
  select option in "${options[@]}" Exit; do
    case $option in
    Exit)
      echo "Exiting..."
      exit 0
      ;;
    *)
      if [[ -n $option ]]; then # Check if a valid choice was made
        # Extract name and ID from selected option
        droplet_name=$(echo "$option" | cut -d' ' -f1)
        # shellcheck disable=SC2116
        droplet_id=$(echo "$option" | grep -oP '(?<=ID: )\d+')
        break
      else
        echo "Invalid selection."
        exit 1

      fi
      ;;
    esac
  done
  echo "$droplet_name $droplet_id" # Return both name and ID
}

droplet_name_and_id=($(select_droplet)) # Store both name and ID in an array
echo "Selected Droplet: ${droplet_name_and_id[0]} (ID: ${droplet_name_and_id[1]})"
droplet_name=${droplet_name_and_id[0]} # Extract the name
droplet_id=${droplet_name_and_id[1]}   # Extract the ID

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
    while ! docker node ps "$droplet_name" -q --filter "desired-state=Ready"; do
      echo "Waiting for node to drain..."
      sleep 5
    done
    sleep 5 # Wait for the services to shutdown
    echo "Droplet is fully drained
		Removing node $droplet_name from Swarm..."
    notify "## Removing Node: **$droplet_name** from Swarm"
    node_ip=$(get_ip_from_node "$droplet_name")
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$node_ip" "docker swarm leave"
    sleep 3
    docker node rm "$droplet_name" --force
  fi
fi

read -r -p "Are you sure you want to delete Droplet \"$droplet_name?\" (please enter the droplet's name) " confirm_name
if [ "$confirm_name" == "$droplet_name" ]; then
  echo "Deleting droplet $droplet_name..."
  notify "## Deleting Droplet: **$droplet_name**"
  notify "> Droplet **$droplet_name** has been removed from the Swarm cluster. Deleting droplet..."
  doctl compute droplet delete "$droplet_id" -f
  notify "> Droplet **$droplet_name** is deleted!"
  update_inventory
else
  echo "Deletion cancelled."
fi
