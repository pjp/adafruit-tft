RECIPIENTNAME="Paul Pearce"
RECIPIENTADDR=paul@pearceful.net
SENDER=pi-speed-mon@pearceful.net
SPEED_FILE="/tmp/speed.txt"

TMPFILE=$(/bin/mktemp)

echo "To: \"$RECIPIENTNAME\" $RECIPIENTADDR" > $TMPFILE
echo "From: $SENDER" >> $TMPFILE
echo "Subject: Prometheus Stats" >> $TMPFILE

~/bin/get-speed-history-summaries-from-prometheus.sh 6 >> $TMPFILE
echo "#====================================" >> $TMPFILE

~/bin/get-cpu-temp-history-from-prometheus.sh 360 >> $TMPFILE
echo "#====================================" >> $TMPFILE

cat $TMPFILE | /usr/sbin/ssmtp paul@pearceful.net

rm $TMPFILE
