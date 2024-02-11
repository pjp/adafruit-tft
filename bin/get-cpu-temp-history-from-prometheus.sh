#!/usr/bin/bash

RANGE="${1:-60m}"

echo "########################"
echo "# History of CPU temp."
echo "# over the last $RANGE"
echo "########################"

# curl -s  "http://localhost:9090/api/v1/query?query=node_thermal_zone_temp\[${RANGE}m\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$' | awk '{printf "%3.1f\n", $1}' | ~/bin/calc-stats.sh "node_thermal_zone_temp deg. C"

source $HOME/bin/prometheus-lib.sh

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list node_thermal_zone_temp ${RANGE})" "node_thermal_zone_temp deg. C"
