#!/bin/bash -f
#
# syntax check-iops.sh!devfullpath
# e.g. check-iops.sh!/dev/dm-1
# device can me softlink
#
# initial data
#
export FULLPATHPARTITIONCHECK=$1
export PARTITION=`basename $1`
export MAJORNU=`echo "ibase=16; \`stat -L -c "%t" $1 | tr '[a-f]' '[A-F]' \`"|bc`
export MINORNU=`echo "ibase=16; \`stat -L -c "%T" $1 | tr '[a-f]' '[A-F]' \`"|bc`
#
# LAST MEASUREMENT VALUES
#
export LASTPROBESECONDS=`cat /tmp/check-iops-lastprobe-seconds-$PARTITION|grep SECONDS|awk -F\  '{print $2}'`
export LASTIOREAD=`cat /tmp/check-iops-lastprobe-seconds-$PARTITION|grep IOREAD|awk -F\  '{print $2}'`
export LASTIOWRITE=`cat /tmp/check-iops-lastprobe-seconds-$PARTITION|grep IOWRITE|awk -F\  '{print $2}'`
#
# CURRENT MEASUREMENT VALUES
#
export CURRENTPROBESECONDS=`date +%s`
export DISKDATA=`cat /proc/diskstats |awk -F\  '{print $1" "$2" "$4" "$8}'|grep ^$MAJORNU\ $MINORNU`
export IOREAD=`echo $DISKDATA  |awk -F\  '{print $3}'`
export IOWRITE=`echo $DISKDATA  |awk -F\  '{print $4}'`
#
# DIFFERENCE
#
export DIFFSECONDS=`echo "$CURRENTPROBESECONDS - $LASTPROBESECONDS" | bc`
export DIFFIOREAD=`echo "$IOREAD - $LASTIOREAD" | bc `
export DIFFIOWRITE=`echo "$IOWRITE - $LASTIOWRITE" | bc`
export DIFFIOTOTAL=`echo "$DIFFIOREAD + $DIFFIOWRITE" | bc `
#
# store new values
#
echo SECONDS\ $CURRENTPROBESECONDS > /tmp/check-iops-lastprobe-seconds-$PARTITION
echo IOREAD\ $IOREAD  >> /tmp/check-iops-lastprobe-seconds-$PARTITION
echo IOWRITE\ $IOWRITE >> /tmp/check-iops-lastprobe-seconds-$PARTITION
#
# calculations
#
export IOREADRATE=`echo "scale=0; $DIFFIOREAD/$DIFFSECONDS"|bc -l`
export IOWRITERATE=`echo "scale=0; $DIFFIOWRITE/$DIFFSECONDS"|bc -l`
export IOTOTALRATE=`echo "scale=0; $DIFFIOTOTAL/$DIFFSECONDS"|bc -l`
#
# output
#
echo " " >> /tmp/debug_check_iops
echo DEVICE: $FULLPATHPARTITIONCHECK >> /tmp/debug_check_iops
echo READ: $IOREAD - $LASTIOREAD    WRITE: $IOWRITE - $LASTIOWRITE        TIME: $DIFFSECONDS   >> /tmp/debug_check_iops
echo READIOPS: $IOREADRATE  WRITEIOPS=$IOWRITERATE TOTALIOPS=$IOTOTALRATE >> /tmp/debug_check_iops
echo ====  >> /tmp/debug_check_iops
echo " "  >> /tmp/debug_check_iops

echo "READIOPS: $IOREADRATE  WRITEIOPS=$IOWRITERATE TOTALIOPS=$IOTOTALRATE|readiops=$IOREADRATE writeiops=$IOWRITERATE totaliops=$IOTOTALRATE"