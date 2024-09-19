#!/usr/bin/env bash

set -e
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )" || exit 1 # cd to the directory of the script to ensure relative paths work

ansible-playbook -i inventory.ini playbooks/update.yml
