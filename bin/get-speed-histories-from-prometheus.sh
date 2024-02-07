#|/bin/bash

RANGE="${1:-6}"

echo "########################"
echo "# History of download/upload speeds from $RANGE hours back, latest values first"
echo "########################"

curl -s  "http://localhost:9090/api/v1/query?query=speedtest_download_bits_per_second\[${RANGE}h\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$' | awk '{printf "Download %4.0fMb/s\n", $1/1000000}' | tac
curl -s  "http://localhost:9090/api/v1/query?query=speedtest_upload_bits_per_second\[${RANGE}h\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$'   | awk '{printf "Upload   %4.0fMb/s\n", $1/1000000}' | tac
