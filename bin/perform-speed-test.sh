#!/bin/bash

export PATH="$HOME/bin:$PATH"

curl -s localhost:9798/metrics | grep -v '^#' | grep 'load' | sed 's/_bits_per_second//' | awk '{ printf "%-25s %4dMb/s\n", $1, $2/1000000}' > ${1:-/tmp/speed.txt}

mail-current-speedtest-results.sh
