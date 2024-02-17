#!/bin/bash

export PATH="$HOME/bin:$PATH"

#############################################
# Set this to a script that will do something
# interesting e.g. sent an email maybe
#
# POST_HOOK_SCRIPT=""

curl -s localhost:9798/metrics | grep -v '^#' | grep 'load' | sed 's/_bits_per_second//' | awk '{ printf "%-25s %4dMb/s\n", $1, $2/1000000}' > ${1:-/tmp/speed.txt}

###########################################
# Check to see if a post hook was specified
#
if [ ! -z "$POST_HOOK_SCRIPT" ]
then
   $POST_HOOK_SCRIPT
fi
