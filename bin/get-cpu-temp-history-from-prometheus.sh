#|/bin/bash

RANGE="${1:-60}"

echo "########################"
echo "# History of CPU temp. from $RANGE minute(s) back"
echo "########################"

# curl -s  "http://localhost:9090/api/v1/query?query=node_thermal_zone_temp\[${RANGE}m\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$' | awk '{printf "%3.1f\n", $1}' | ~/bin/calc-stats.sh "node_thermal_zone_temp deg. C"

(source ~/bin/prometheus-lib.sh ; prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list node_thermal_zone_temp ${RANGE}m)" "node_thermal_zone_temp deg. C")
