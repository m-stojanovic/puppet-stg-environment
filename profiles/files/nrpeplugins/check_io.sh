#!/bin/bash -f
#
# syntax check-io.sh!devfullpath!sectorsize
# e.g. check-io.sh!/dev/dm-1!sectorsize
# device can me softlink
#
# initial data
#
export FULLPATHPARTITIONCHECK=$1
export SECSIZE=$2
export PARTITION=`basename $1`
export MAJORNU=`echo "ibase=16; \`stat -L -c "%t" $1 | tr '[a-f]' '[A-F]' \`"|bc`
export MINORNU=`echo "ibase=16; \`stat -L -c "%T" $1 | tr '[a-f]' '[A-F]' \`"|bc`
#
# LAST MEASUREMENT VALUES
#
export LASTPROBESECONDS=`cat /tmp/check-io-lastprobe-seconds-$PARTITION|grep SECONDS|awk -F\  '{print $2}'`
export LASTSECREAD=`cat /tmp/check-io-lastprobe-seconds-$PARTITION|grep SECREAD|awk -F\  '{print $2}'`
export LASTSECWRITE=`cat /tmp/check-io-lastprobe-seconds-$PARTITION|grep SECWRITE|awk -F\  '{print $2}'`
export LASTIOMILISEC=`cat /tmp/check-io-lastprobe-seconds-$PARTITION|grep IOMILISEC|awk -F\  '{print $2}'`
#
# CURRENT MEASUREMENT VALUES
#
export CURRENTPROBESECONDS=`date +%s`
export DISKDATA=`cat /proc/diskstats |awk -F\  '{print $1" "$2" "$6" "$10" "$13}'|grep ^$MAJORNU\ $MINORNU`
export SECREAD=`echo $DISKDATA  |awk -F\  '{print $3}'`
export SECWRITE=`echo $DISKDATA  |awk -F\  '{print $4}'`
export IOMILISEC=`echo $DISKDATA  |awk -F\  '{print $5}'`
#
# DIFFERENCE
#
export DIFFSECONDS=`echo "$CURRENTPROBESECONDS - $LASTPROBESECONDS" | bc`
export DIFFSECREAD=`echo "$SECREAD - $LASTSECREAD" | bc `
export DIFFSECWRITE=`echo "$SECWRITE - $LASTSECWRITE" | bc`
export DIFFIOMILISEC=`echo "$IOMILISEC - $LASTIOMILISEC" | bc`
#
# store new values
#
echo SECONDS\ $CURRENTPROBESECONDS > /tmp/check-io-lastprobe-seconds-$PARTITION
echo SECREAD\ $SECREAD  >> /tmp/check-io-lastprobe-seconds-$PARTITION
echo SECWRITE\ $SECWRITE >> /tmp/check-io-lastprobe-seconds-$PARTITION
echo IOMILISEC\ $IOMILISEC >> /tmp/check-io-lastprobe-seconds-$PARTITION
#
# calculations
#
export PERSENTAGEUSAGE=`echo "$DIFFIOMILISEC/($DIFFSECONDS*10)"|bc`
export SECREADRATE=`echo $DIFFSECREAD/$DIFFSECONDS|bc -l`
export SECWRITERATE=`echo $DIFFSECWRITE/$DIFFSECONDS|bc -l`
export MBREADRATE=`echo "scale=3;($SECREADRATE*$SECSIZE)/1048576"|bc -l| sed -r 's/^\./0./g'|sed -r 's/^0$/0.000/'`
export MBWRITERATE=`echo "scale=3;($SECWRITERATE*$SECSIZE)/1048576"|bc -l| sed -r 's/^\./0./g'|sed -r 's/^0$/0.000/'`
#
# output
#
echo " " >> /tmp/debug_check_io
echo READ: $SECREAD - $LASTSECREAD    WRITE: $SECWRITE - $LASTSECWRITE        TIME: $DIFFSECONDS      IOTIME: $IOMILISEC - $LASTIOMILISEC  >> /tmp/debug_check_io
echo READSPEED: $MBREADRATE   WRITESPEED: $MBWRITERATE        UTILIZATION: $PERSENTAGEUSAGE%  >> /tmp/debug_check_io
echo UTILIZATION: $PERSENTAGEUSAGE%\|mbread=$MBREADRATE mbwrite=$MBWRITERATE utilization=$PERSENTAGEUSAGE >> /tmp/debug_check_io
echo ====  >> /tmp/debug_check_io
echo " "  >> /tmp/debug_check_io

if [ $PERSENTAGEUSAGE -ge 90 ] ; then
echo UTILIZATION CRITICAL: $PERSENTAGEUSAGE%\|mbread=$MBREADRATE mbwrite=$MBWRITERATE utilization=$PERSENTAGEUSAGE
exit 2
fi

if [ $PERSENTAGEUSAGE -ge 80 ] ; then
echo UTILIZATION WARNING: $PERSENTAGEUSAGE%\|mbread=$MBREADRATE mbwrite=$MBWRITERATE utilization=$PERSENTAGEUSAGE
exit 1
fi

if [ $PERSENTAGEUSAGE -ge 0 ] ; then
echo UTILIZATION NORMAL: $PERSENTAGEUSAGE%\|mbread=$MBREADRATE mbwrite=$MBWRITERATE utilization=$PERSENTAGEUSAGE
exit 0
fi

echo UTILIZATION UNKNWOWN: $PERSENTAGEUSAGE%\|mbread=$MBREADRATE mbwrite=$MBWRITERATE utilization=$PERSENTAGEUSAGE
exit 4
