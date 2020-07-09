#!/bin/bash

#
# Initialization
#
SCRIPT="$0"
SCRIPT_NAME="$(basename "$SCRIPT")"
SCRIPT_SHORTNAME="${SCRIPT_NAME%.sh}"
SCRIPT_PID="$$"

PREFIX="/usr/lib/nagios/plugins"
WORKDIR="/var/nagios"
TMPDIR="/tmp"
LOGDIR="${WORKDIR}"
export WORKDIR TMPDIR LOGDIR

LOGFILE="${LOGDIR}/${SCRIPT_SHORTNAME}.log"
TMPFILE="${TMPDIR}/${SCRIPT_SHORTNAME}.tmp"
export LOGFILE TMPFILE

TIMESTAMP="date"
export TIMESTAMP

HEADER="IFTRAFFIC"
STATE="UNKNOWN"
RC="3"

PROCFILE="/proc/net/dev"
if [ ! -r ${PROCFILE} ]; then
        echo -n "$HEADER $STATE ${PROCFILE} not readable."
        exit $RC;
fi

while getopts i: OPTION; do
        case $OPTION in
                i) INTERFACE=$OPTARG ;;
        esac
done

if [ -z "${INTERFACE}" ]; then
        echo -n "No interface given."
        exit $RC;
fi

#
# Main
#

#
# Interface traffic
#
IFTRAFFIC="$(cat ${PROCFILE} | grep -E "${INTERFACE}")"
IFTRAFFIC="${IFTRAFFIC##*:}"

RX_BYTES="$(echo ${IFTRAFFIC} | awk '{print $1}')"
RX_PACKETS="$(echo ${IFTRAFFIC} | awk '{print $2}')"
RX_ERRORS="$(echo ${IFTRAFFIC} | awk '{print $3}')"
RX_DROP="$(echo ${IFTRAFFIC} | awk '{print $4}')"
RX_FIFO="$(echo ${IFTRAFFIC} | awk '{print $5}')"
RX_FRAME="$(echo ${IFTRAFFIC} | awk '{print $6}')"
RX_COMPRESSED="$(echo ${IFTRAFFIC} | awk '{print $7}')"
RX_MULTICAST="$(echo ${IFTRAFFIC} | awk '{print $8}')"
TX_BYTES="$(echo ${IFTRAFFIC} | awk '{print $9}')"
TX_PACKETS="$(echo ${IFTRAFFIC} | awk '{print $10}')"
TX_ERRORS="$(echo ${IFTRAFFIC} | awk '{print $11}')"
TX_DROP="$(echo ${IFTRAFFIC} | awk '{print $12}')"
TX_FIFO="$(echo ${IFTRAFFIC} | awk '{print $13}')"
TX_COLLS="$(echo ${IFTRAFFIC} | awk '{print $14}')"
TX_CARRIER="$(echo ${IFTRAFFIC} | awk '{print $15}')"
TX_COMPRESSED="$(echo ${IFTRAFFIC} | awk '{print $16}')"

STATE="OK"
RC="0"
echo "$HEADER $STATE;|rx_bytes=${RX_BYTES}c rx_packets=${RX_PACKETS}c rx_errors=${RX_ERRORS}c rx_drop=${RX_DROP}c rx_fifo=${RX_FIFO}c rx_frame=${RX_FRAME}c rx_compressed=${RX_COMPRESSED}c rx_multicast=${RX_MULTICAST}c tx_bytes=${TX_BYTES}c tx_packets=${TX_PACKETS}c tx_errors=${TX_ERRORS}c tx_drop=${TX_DROP}c tx_fifo=${TX_FIFO}c tx_colls=${TX_COLLS}c tx_carrier=${TX_CARRIER}c tx_compressed=${TX_COMPRESSED}c"

exit $RC
