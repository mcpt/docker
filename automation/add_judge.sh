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
  exit
fi
JUDGE_NAME=$1


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
    --constraint 'node.role == worker' \
    --network judge \
    --cap-add SYS_PTRACE \
    --mount type=bind,src=/var/share/problems/,dst=/problems/ \
    ghcr.io/dmoj/runtimes-tier3:amd64-latest \
    run -p 9999 -c /problems/judge.yml "localhost" "$JUDGE_NAME" "$JUDGE_AUTH_KEY"