#!/usr/bin/env bash

set -e


ansible-playbook -i inventory.ini playbooks/update.yml
