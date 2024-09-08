#!/usr/bin/env bash

set -e
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

ansible-playbook -i inventory.ini playbooks/update.yml
