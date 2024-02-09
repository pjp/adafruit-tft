#!/bin/bash
curl -s 'http://localhost:9090/api/v1/query?query=last_over_time(node_thermal_zone_temp\[1h\])' | jq -r '.data.result[0].value[1]'
