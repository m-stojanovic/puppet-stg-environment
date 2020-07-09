#!/bin/bash
threads=$(cut -d" " -f 4 /proc/loadavg | cut -d/ -f 2)
echo "PUTVAL $(hostname)/mapp-threads/count-all N:$threads"
