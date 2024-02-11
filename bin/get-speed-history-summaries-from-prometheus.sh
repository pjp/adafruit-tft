#!/usr/bin/bash

RANGE="${1:-6h}"

echo "########################"
echo "# History of download/upload speeds"
echo "# over the last $RANGE"
echo "########################"
#curl -s  "http://localhost:9090/api/v1/query?query=speedtest_download_bits_per_second\[${RANGE}h\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$' | awk '{printf "%4.0f\n", $1/1000000}' | ~/bin/calc-stats.sh "speedtest_download Mb/s"

#curl -s  "http://localhost:9090/api/v1/query?query=speedtest_upload_bits_per_second\[${RANGE}h\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$'   | awk '{printf "%4.0f\n", $1/1000000}' | ~/bin/calc-stats.sh "speedtest_upload Mb/s"


source $HOME/bin/prometheus-lib.sh

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list speedtest_download_bits_per_second ${RANGE} | awk '{printf "%4.0f\n", $1/1000000}')" "speedtest_download Mb/s"

prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list speedtest_upload_bits_per_second ${RANGE} | awk '{printf "%4.0f\n", $1/1000000}')" "speedtest_upload Mb/s"
