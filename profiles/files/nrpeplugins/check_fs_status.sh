#!/bin/bash
ROFS=`dmesg -T|grep "Read-only file system"|wc -l`
IOERR=`dmesg -T|grep "I/O error"|wc -l`
RESW=`dmesg -T|grep "Read-error on swap-device"|wc -l`
EXTERR=`dmesg -T|grep EXT|grep error\ |wc -l`
touch /tmp/.nagios_check_filesystem
TOUCHTMP=$?

TXT=""
TXT1=""
TXT2=""
TXT3=""
if [[ $TOUCHTMP -gt 0 ]]; then
 ECCODE=2
 TXT="/tmp Read only file system"
fi
if [[ $ROFS -gt 0 ]]; then
 ECCODE=2
 TXT="Read only file system. Errors $ROFS"
fi
if [[ IOERR -gt 0 ]]; then
 ECCODE=2
 TXT=$TXT" ## I/O errors $IOERR"
fi
if [[ RESW -gt 0 ]]; then
 ECCODE=2
 TXT=$TXT" ## SWAP read errors $RESW"
fi
if [[ EXTERR -gt 0 ]]; then
 ECCODE=2
 TXT=$TXT" ## EXT errors $EXTERR"
fi


if [[ $ROFS -eq 0 ]] && [[ $IOERR -eq 0 ]] && [[ $RESW -eq 0 ]] && [[ $EXTERR -eq 0 ]] && [[ $TOUCHTMP -eq 0 ]]; then
 ECCODE=0
 TXT="No errors on filesystems"
fi
echo $TXT
exit $ECCODE