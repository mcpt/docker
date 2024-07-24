#!/usr/bin/env bash

set -e


ansible-playbook -i inventory/hosts playbooks/update.yml
