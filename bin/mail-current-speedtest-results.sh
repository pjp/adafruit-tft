RECIPIENTNAME="Paul Pearce"
RECIPIENTADDR=paul@pearceful.net
SENDER=pi-speed-mon@pearceful.net
SPEED_FILE="/tmp/speed.txt"

TMPFILE=$(/bin/mktemp)

echo "To: \"$RECIPIENTNAME\" $RECIPIENTADDR" > $TMPFILE
echo "From: $SENDER" >> $TMPFILE
echo "Subject: Speed Test Results" >> $TMPFILE

#curl -s localhost:9798/metrics | grep -v '^#' | grep 'load' | sed 's/_bits_per_second//' | awk '{ printf "%-25s %4dMb/s\n", $1, $2/1000000}' | tee /tmp/speed.txt >> $TMPFILE

#bin/perform-speed-test.sh $SPEED_FILE
#cat $SPEED_FILE >> $TMPFILE

~/bin/get-speed-histories-from-prometheus.sh >> $TMPFILE
cat $TMPFILE | /usr/sbin/ssmtp paul@pearceful.net

rm $TMPFILE
