#!/usr/bin/env bash
# Confirm you're running on general and as root

set -e # exit on error
set -x # print each command before executing it
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$HOSTNAME" != "general" ]
  then echo "Please run on general"
  exit
fi

. /home/judge/docker/dmoj/scripts/utils/notify

# check if name was provided
if [ -z "$1" ]
  then echo "Please provide a name for the judge"
  exit
fi
JUDGE_NAME=$1


# Create new judge object in db
function run_single_command_on_site() {
  # find out which node site is running on
  SITE_NODE=$(docker service ps wlmoj_site --format "{{.Node}}" --filter desired-state=running)
  # keep running the command if there is no node
  while [ "$SITE_NODE" = "" ]; do
    SITE_NODE=$(docker service ps wlmoj_site --format "{{.Node}}" --filter desired-state=running)
  done

  # get node's local ip
  NODE_IP=$(docker node inspect --format '{{ .Status.Addr  }}' "$SITE_NODE")

  # run the command
  sudo ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$NODE_IP" <<EOF
  # get id of the site container
  SITE_ID=\$(docker ps --filter name=wlmoj_site --format "{{.ID}}")
  docker exec -i \$SITE_ID /bin/bash -c "$1"
EOF
}

rand=$(head -c 75 /dev/urandom | tr -d '\0')
# Convert bytes to Base64
JUDGE_AUTH_KEY=$(echo "$rand" | base64 | tr -d '\n' | cut -c -90 ) # db type is varchar(100)

notify "Attempting to create new judge $JUDGE_NAME"
run_single_command_on_site "python3 manage.py shell -c 'from judge.models import Judge; Judge.objects.create(name=\"'\"$JUDGE_NAME\"'\", auth_key=r\"'\"$JUDGE_AUTH_KEY\"'\")'"

notify "Judge $JUDGE_NAME's DB obj was created"
docker service create \
    --name "judge_${JUDGE_NAME}" \
    --env JUDGE_NAME="${JUDGE_NAME}" \
    --env AUTH_KEY="${JUDGE_AUTH_KEY}" \
    --replicas 1 \
    --constraint 'node.role == worker' \
    --network judge \
    --cap-add SYS_PTRACE \
    --mount type=bind,src=/var/share/problems/,dst=/problems/ \
    ghcr.io/dmoj/runtimes-tier3:amd64-latest