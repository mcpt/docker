#!/usr/bin/env bash

# A simple script to update --deteach the docker swarm. This script is meant to be run on the manager node (general) and will update --deteach the stack.

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

if [ ! -d /home/judge/docker ]; then
  echo "Directory /home/judge/docker does not exist. Please rethink the machine you are running this on... :)"
  exit 1
fi

cd /home/judge/docker || exit
echo "Pulling changes..."
git stash
git pull
git stash pop

# check if the user called the script with any specific service, if so update only that service
if [ "$1" != "" ]; then
  echo "Updating only $1..."
  docker service update wlmoj_"$1" --image ghcr.io/mcpt/wlmoj-"$1"
  exit 0
else
  echo "Updating all services..."
  # Don't use docker stack deploy as that would also update the services that are not changed.
  # texoid
  docker service update --deteach wlmoj_textoid --image ghcr.io/mcpt/wlmoj-texoid
  # pdfoid
  docker service update --deteach wlmoj_pdfoid --image ghcr.io/mcpt/wlmoj-pdfoid
  # mathoid
  docker service update --deteach wlmoj_mathoid --image ghcr.io/mcpt/wlmoj-mathoid
  # site
  docker service update --deteach wlmoj_site --image ghcr.io/mcpt/wlmoj-site
  # celery
  docker service update --deteach wlmoj_celery --image ghcr.io/mcpt/wlmoj-celery
  # bridged
  docker service update --deteach wlmoj_bridged --image ghcr.io/mcpt/wlmoj-bridged
  # wsevent
  docker service update --deteach wlmoj_wsevent --image ghcr.io/mcpt/wlmoj-wsevent
  # backups
  docker service update --deteach wlmoj_backups --image ghcr.io/mcpt/wlmoj-backups

# Don't update nginx automatically, as it will cause downtime. Update it manually. via passing the nginx flag to this script.
fi

echo "Done updating services."

# check if the --no-static or -ns flag is passed, if so don't update the static files
if ! has_param '-ns' "$@" || ! has_param '--no-static' "$@"; then
  # ask the user if they want to update the static files
  read -r -p "Do you want to update the static files? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Updating static files..."
    # ask for root perms
    sudo -v || exit 1
    update_static

  else
    echo "Skipping static files update..."

  fi

fi

function update_static() {
  # find out which node site is running on
  SITE_NODE=$(docker service ps wlmoj_site --format "{{.Node}}" --filter desired-state=running)
  # keep running the command if there is no node
  while [ "$SITE_NODE" = "" ]; do
    SITE_NODE=$(docker service ps wlmoj_site --format "{{.Node}}" --filter desired-state=running)
  done

  # get node's local ip
  NODE_IP=$(docker node inspect --format '{{ .Status.Addr  }}' "$SITE_NODE")

  # update the site

  sudo ssh -f -q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$NODE_IP"  <<EOF
  # get id of the site container
  SITE_ID=\$(docker ps --filter name=wlmoj_site --format "{{.ID}}")
  docker exec -it \$SITE_ID /bin/bash -c "/scripts/copy_static"
EOF

  ls
}
