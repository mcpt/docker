#!/usr/bin/env bash

# This script is the entrypoint for the WLMOJ site server
#

bash /scripts/copy_static # todo: Refactor into just a update script to speed up deployment times

uwsgi --ini /uwsgi.ini