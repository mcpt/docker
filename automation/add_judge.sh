#!/usr/bin/env bash
# Confirm you're running on general and as root

set -e # exit on error
#set -x # print each command before executing it
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ "$HOSTNAME" != "general" ]
  then echo "Please run on general"
  exit
fi

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )" # cd to the directory of this script

. /home/judge/docker/dmoj/scripts/utils/notify
. ./utils/commands.sh

# check if name was provided
if [ -z "$1" ]
  then echo "Please provide a name for the judge"
  echo "Usage: $0 <judge_name> <droplet_name_to_run_on (optional)> "
  exit
fi
JUDGE_NAME=$1

if [ -z "$2" ]
  then
    # Check if the droplet already exists as a safety measure
    if ! doctl compute droplet list --format Name | grep -i "$1"; then
        echo "Droplet $1 does not exist!" >&2
        exit 1
    fi
    CONSTRAINT="node.name == $(doctl compute droplet list --format Name | grep -i "$1" | awk '{print $1}')"
else
    CONSTRAINT="node.role == worker"
fi


rand=$(head -c 75 /dev/urandom | tr -d '\0')
# Convert bytes to Base64
JUDGE_AUTH_KEY=$(echo "$rand" | base64 | tr -d '\n' | cut -c -90 ) # db type is varchar(100)

notify "Attempting to create new judge $JUDGE_NAME"
# Warning for future devs: THE LINE BELOW IS A PAIN TO WRITE/DEAL WITH. I KNOW IT'S UGLY. I'M SORRY.
run_single_command_on_site "python3 manage.py shell -c 'from judge.models import Judge; Judge.objects.create(name=\"'\"$JUDGE_NAME\"'\", auth_key=r\"'\"$JUDGE_AUTH_KEY\"'\")'"

notify "Judge $JUDGE_NAME's DB obj was created"


docker service create \
    --name "judge_${JUDGE_NAME}" \
    --env JUDGE_NAME="${JUDGE_NAME}" \
    --env AUTH_KEY="${JUDGE_AUTH_KEY}" \
    --replicas 1 \
    --constraint "$CONSTRAINT" \
    --network wlmoj_judge \
    --cap-add SYS_PTRACE \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.judge.rule=Host(\`judge\`)" \
    --label "traefik.http.services.${JUDGE_NAME}.loadbalancer.server.port=9999" \
    --mount type=bind,src=/var/share/problems/,dst=/problems/ \
    ghcr.io/mcpt/wlmoj-judge:latest \
    run -p 9999 -c /judge.yml "bridged" "$JUDGE_NAME" "$JUDGE_AUTH_KEY"