#############################################################
# A simple library of functions to get values from prometheus
#############################################################
#
# Written by Paul Pearce - Febuary 2024
#
#######################################
# Designed to be referenced in scipts as 
#
# source ~/bin/Prometyheus-lib.sh
#
#
# These functions can also be called directly on the command line
# in a sub-shell e.g. for the metrics 
#
#    node_thermal_zone_temp
#    speedtest_download_bits_per_second 
#    speedtest_upload_bits_per_second 
#
##############################################
# (source ~/bin/prometheus-lib.sh ; prometheus-lib-get-latest-value node_thermal_zone_temp 1m)
#
# (source ~/bin/prometheus-lib.sh ; prometheus-lib-get-history-as-list node_thermal_zone_temp 1m)
#
# (source ~/bin/prometheus-lib.sh ; prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list node_thermal_zone_temp 1h)" "History")
#
#
###############################################
# Need to massage the output to Mb/s using awk.
#
# Since the upload/download speed is only 
# captured once an hour, we need to go back a 
# few hours.
#
# (source ~/bin/prometheus-lib.sh ; prometheus-lib-get-latest-value speedtest_download_bits_per_second 1h | awk '{printf "%4.0f\n", $1/1000000}')
#
# (source ~/bin/prometheus-lib.sh ; prometheus-lib-get-history-as-list speedtest_download_bits_per_second 6h | awk '{printf "%4.0f\n", $1/1000000}')
#
# (source ~/bin/prometheus-lib.sh ; prometheus-lib-get-stats-from-list "$(prometheus-lib-get-history-as-list speedtest_download_bits_per_second 6h | awk '{printf "%4.0f\n", $1/1000000}')" "History")
#
#############################################################
#
export PROMETHEUS_API="http://localhost:9090/api/v1"

##########################
function prometheus-lib-get-history-as-list() {
##########################
   local metric="$1"
   local range="$2"

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need metric & range" >&2
   else
      curl -s  "${PROMETHEUS_API}/query?query=${metric}\[${range}\]" | jq -r '.data.result[0].values| map(.[1])' | tr -d '[],"' | grep -v '^$' | awk '{printf "%3.1f\n", $1}'
   fi
}

#######################
function prometheus-lib-get-latest-value() {
#######################
   local metric="$1"
   local range="$2"

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need metric & range" >&2
   else
      curl -s "${PROMETHEUS_API}/query?query=last_over_time(${metric}\[${range}\])" | jq -r '.data.result[0].value[1]'
   fi

}

##################################
function prometheus-calc-stats-from-list() {
##################################
   local list="$1"
   local label="$2"

   echo "$list" | sort -n | awk -v label="${label:-Not specified}" '
  BEGIN {
    c = 0;
    sum = 0;
  }
  $1 ~ /^(\-)?[0-9]*(\.[0-9]*)?$/ {
    a[c++] = $1;
    sum += $1;
  }
  END {
    ave = sum / c;
    printf "# Label : %s\n", label ;
    printf "%-7s %9s %9s %9s\n", "# Count", "Avg", "Min", "Max" ;
    printf "%7d %9.1f %9.1f %9.1f\n", c, ave, a[0], a[c-1];
  }
'
}

######################
function prometheus-lib-get-stats-from-list() {
######################
   local list="$1"
   local label="$2"

   if [ $# -lt 2 ]
   then
      echo "Too few parameters, need list & label" >&2
   else
      # echo "$list" | ~/bin/calc-stats.sh "$label"
      prometheus-calc-stats-from-list "$list" "$label"
   fi
}

