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

. ../automation/utils/commands.sh


run_single_command_on_site "$1"