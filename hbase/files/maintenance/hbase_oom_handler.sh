#!/bin/sh

PID=$1

logger -i -s -p user.err -t HBASE "Killing (SIGKILL) HBASE process ID $PID due to OOM Error"
kill -9 $PID
