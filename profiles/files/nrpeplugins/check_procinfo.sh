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

HEADER="PROCINFO"
STATE="UNKNOWN"
RC="3"

#
# Procinfo needs a terminal
#
export TERM="xterm"

PROCINFO="$(which procinfo)"
if [ ! -x ${PROCINFO} ]; then
        echo -n "$HEADER $STATE ${PROCINFO} not installed."
        exit $RC;
fi

#
# Main
#

#
# System load and processes
#
SYSTEM_USAGE="$(${PROCINFO} -s | grep -E ^"Bootup:" | awk '{printf("%s %s %s %s", $9, $10, $11, $12)}')"
LOAD1="$(echo ${SYSTEM_USAGE} | awk '{print $1}')"
LOAD5="$(echo ${SYSTEM_USAGE} | awk '{print $2}')"
LOAD15="$(echo ${SYSTEM_USAGE} | awk '{print $3}')"

PROCS="$(echo ${SYSTEM_USAGE} | awk '{print $4}')"
PROCS_RUNABLE="${PROCS%%/*}"
PROCS_TOTAL="${PROCS##*/}"

#
# CPU usage
#
CPU_USAGE_RAW="$(cat /proc/stat | grep -e "^cpu ")"
CPU_USERSPACE="$(echo ${CPU_USAGE_RAW} | awk '{print $2}')"
if [ -n "${CPU_USERSPACE}" ]; then
   CPU_USAGE="${CPU_USERSPACE}";
else
   CPU_USAGE="U";
fi

CPU_NICE="$(echo ${CPU_USAGE_RAW} | awk '{print $3}')"
if [ -n "${CPU_NICE}" ]; then
   CPU_USAGE="${CPU_USAGE} ${CPU_NICE}";
else
   CPU_NICE="U";
fi

CPU_KERNELSPACE="$(echo ${CPU_USAGE_RAW} | awk '{print $4}')"
if [ -n "${CPU_KERNELSPACE}" ]; then
   CPU_USAGE="${CPU_USAGE} ${CPU_KERNELSPACE}";
else
   CPU_KERNELSPACE="U";
fi

CPU_IDLE="$(echo ${CPU_USAGE_RAW} | awk '{print $5}')"
if [ -n "${CPU_IDLE}" ]; then
   CPU_USAGE="${CPU_USAGE} ${CPU_IDLE}";
else
   CPU_IDLE="U";
fi

CPU_IOWAIT="$(echo ${CPU_USAGE_RAW} | awk '{print $6}')"
if [ -n "${CPU_IOWAIT}" ]; then
   CPU_USAGE="${CPU_USAGE} ${CPU_IOWAIT}";
else
   CPU_IOWAIT="U";
fi

CPU_HWIRQ="$(echo ${CPU_USAGE_RAW} | awk '{print $7}')"
if [ -n "${CPU_HWIRQ}" ]; then
   CPU_USAGE="${CPU_USAGE} ${CPU_HWIRQ}";
else
   CPU_HWIRQ="U";
fi

CPU_SWIRQ="$(echo ${CPU_USAGE_RAW} | awk '{print $8}')"
if [ -n "${CPU_SWIRQ}" ]; then
   CPU_USAGE="${CPU_USAGE} ${CPU_SWIRQ}";
else
   CPU_SWIRQ="U";
fi

CPU_TOTAL="0"
for CPU in ${CPU_USAGE}; do
   CPU_TOTAL="$(echo "${CPU_TOTAL} ${CPU}" | awk '{printf("%.0f", $1 + $2)}')";
done

#
# Paging
#
PAGE_IN="$(${PROCINFO} -s | grep -E "page in :" | cut -c 43-53 | awk '{print $1}' )"
if [ -z "${PAGE_IN}" ]; then
   PAGE_IN="U";
fi

PAGE_OUT="$(${PROCINFO} -s | grep -E "page out:" | cut -c 43-53 | awk '{print $1}' )"
if [ -z "${PAGE_OUT}" ]; then
   PAGE_OUT="U";
fi

PAGE_ACT="$(${PROCINFO} -s | grep -E "page act:" | cut -c 43-53 | awk '{print $1}' )"
if [ -z "${PAGE_ACT}" ]; then
   PAGE_ACT="U";
fi

PAGE_DEA="$(${PROCINFO} -s | grep -E "page dea:" | cut -c 43-53 | awk '{print $1}' )"
if [ -z "${PAGE_DEA}" ]; then
   PAGE_DEA="U";
fi

PAGE_FLT="$(${PROCINFO} -s | grep -E "page flt:" | cut -c 43-53 | awk '{print $1}' )"
if [ -z "${PAGE_FLT}" ]; then
   PAGE_FLT="U";
fi

#
# Swaping
#
SWAPING="$(${PROCINFO} -s | grep -E "swap in :|swap out:" | cut -c 43-53)"
SWAP_IN="$(echo ${SWAPING} | awk '{print $1}')"
SWAP_OUT="$(${PROCINFO} -s | grep "swap out"|awk -F: '{print $5}'|awk '{print $1}')"

#
# Contextswitches
# 
CONTEXTSW="$(${PROCINFO} -s | grep -E "context :" | cut -c 43-53 | awk '{print $1}')"

STATE="OK"
RC="0"
echo "$HEADER $STATE;|load=${LOAD1};${LOAD5};${LOAD15} pr=${PROCS_RUNABLE} pt=${PROCS_TOTAL} u=${CPU_USERSPACE}c n=${CPU_NICE}c k=${CPU_KERNELSPACE}c io=${CPU_IOWAIT}c hw=${CPU_HWIRQ}c sw=${CPU_SWIRQ}c i=${CPU_IDLE}c t=${CPU_TOTAL}c pi=${PAGE_IN}c po=${PAGE_OUT}c pa=${PAGE_ACT}c pd=${PAGE_DEA}c pf=${PAGE_FLT}c si=${SWAP_IN} so=${SWAP_OUT} csw=${CONTEXTSW}c"

exit $RC
