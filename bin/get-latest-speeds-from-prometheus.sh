#!/bin/bash

###########################
# The files to check/create
#
SPEED_FILE="${1:-/tmp/speed.txt}"
SPEED_FILE_TMP="${SPEED_FILE}.from-prometheus"

###################################################################
# Create the temp. speed file with the latest stats from Prometheus
#
echo "speedtest_download $(~/bin/get-latest-download-speed-from-prometheus.sh | awk '{ printf "%4.0fMb/s\n", $1/1000000}')" | tee    $SPEED_FILE_TMP
echo "speedtest_upload   $(~/bin/get-latest-upload-speed-from-prometheus.sh   | awk '{ printf "%4.0fMb/s\n", $1/1000000}')" | tee -a $SPEED_FILE_TMP

#########################################################
# Have the speed outputs changed since the last check ?
#
diff -q $SPEED_FILE $SPEED_FILE_TMP > /dev/null 2>&1
   
if [ $? -gt 0 ]
then
   #################
   # Yes, update the speed file
   #
   cp $SPEED_FILE_TMP $SPEED_FILE
fi
