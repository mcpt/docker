#!/usr/bin/env bash

# A simple script to update --detach the docker swarm. This script is meant to be run on the manager node (general) and will update --detach the stack.

# check the hostname is general as this script is meant to be run on the general node and not on the other nodes.
if [ "$(hostname)" != "general" ]; then
  echo "This script is meant to be run on the general node. Exiting..."
  exit 1
fi

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"


# check if /home/judge/docker exists
has_param() {
  local term="$1"
  shift
  for arg; do
    if [[ $arg == "$term" ]]; then
      return 0
    fi
  done
  return 1
}

# ------ Help Command ------
if has_param '-h' "$@" || has_param '--help' "$@"; then
  echo "Usage: $0 [OPTIONAL_NAME] [FLAGS]"
  echo "Update the docker swarm services."
  echo "If you want to update only a specific service, pass the service name as an argument. (e.g. ./update.sh site)"
  echo "Options:"
  echo "  -h, --help         Show this help message."
  echo "  -sd, --skip-deploy Skip updating the docker services."
  echo "  -ss, --skip-static   Skip updating the static files."
  echo "  -su, --skip-update   Skip updating the site on the nodes."
  echo "note: do not place flags before the service name. (e.g. ./update.sh -sd site) they will be ignored."
  exit 0
fi


if [ ! -d /home/judge/docker ]; then
  echo "Directory /home/judge/docker does not exist. Please rethink the machine you are running this on... :)"
  exit 1
fi

cd /home/judge/docker || exit
echo "Pulling changes..."
git stash
git pull
git stash pop

cp /home/judge/docker/local_settings.py /var/share/configs/wlmoj/local_settings.py

# --------- Static files update ---------

function update_static() {
  # find out which node site is running on
  SITE_NODE=$(docker service ps wlmoj_site --format "{{.Node}}" --filter desired-state=running  | awk "NR==1{print
  \$1}")
  # keep running the command if there is no node
  while [ "$SITE_NODE" = "" ]; do
    SITE_NODE=$(docker service ps wlmoj_site --format "{{.Node}}" --filter desired-state=running  | awk "NR==1{print
    \$1}")
  done

  # get node's local ip
  NODE_IP=$(docker node inspect --format '{{ .Status.Addr  }}' "$SITE_NODE")

  # update the site

  sudo ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$NODE_IP"  <<EOF
  # get id of the site container
  SITE_ID=\$(docker ps --filter name=wlmoj_site --format "{{.ID}}")
  docker exec -u 0 \$SITE_ID  /bin/bash -c "/scripts/copy_static"
EOF
}

if ! (has_param '-su' "$@" || has_param '--skip-update' "$@"); then
  # Ask the user if they want to update the site on the nodes
  read -r -p "Do you want to update the site on the nodes? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Updating site on the nodes..."
    bash /home/judge/docker/automation/update_nodes.sh
  else
    echo "Skipping site update..."
  fi

fi

# check if the --no-static or -ns flag is passed, if so don't update the static files
if ! (has_param '-ss' "$@" || has_param '--skip-static' "$@"); then
  # ask the user if they want to update the static files
  read -r -p "Do you want to update the static files? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Updating static files..."
    update_static
    echo "Static files updated."

  else
    echo "Skipping static files update..."

  fi

fi


if ! ( has_param '-sd' "$@" || has_param '--skip-deploy' "$@"); then
  # check if the user called the script with any specific service, if so update only that service
  if [ "$1" != ""  ] &&  [[ ! "$1" =~ ^- ]]; then # ignore the case where the user passes a flag as the first argument
    echo "Updating only $1..."
    docker service update --force wlmoj_"$1" --image ghcr.io/mcpt/wlmoj-"$1":latest
    exit 0
  else
    echo "Updating all services..."
    # Don't use docker stack deploy as that would also update the services that are not changed.
    # texoid
    docker service update --detach wlmoj_texoid --image ghcr.io/mcpt/wlmoj-texoid
    # pdfoid
    docker service update --detach wlmoj_pdfoid --image ghcr.io/mcpt/wlmoj-pdfoid
    # mathoid
    docker service update --detach wlmoj_mathoid --image ghcr.io/mcpt/wlmoj-mathoid
    # site
    docker service update --detach wlmoj_site --image ghcr.io/mcpt/wlmoj-site
    # celery
    docker service update --detach wlmoj_celery --image ghcr.io/mcpt/wlmoj-celery
    # bridged
    docker service update --detach wlmoj_bridged --image ghcr.io/mcpt/wlmoj-bridged
    # wsevent
    docker service update --detach wlmoj_wsevent --image ghcr.io/mcpt/wlmoj-wsevent
    # backups
#    docker service update --detach wlmoj_backups --image ghcr.io/mcpt/wlmoj-backups

  # Don't update nginx automatically, as it will cause downtime. Update it manually. via passing the nginx flag to this script.
  fi
fi


echo "Done updating services."