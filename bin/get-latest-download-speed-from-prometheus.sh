#!/bin/bash
curl -s 'http://localhost:9090/api/v1/query?query=last_over_time(speedtest_download_bits_per_second\[1h\])' | jq -r '.data.result[0].value[1]'
