#!/bin/bash
export topologies=$1
export all_running=$( /usr/bin/flink list | grep RUNNING | awk -F":" '{print $5}' | tr -d '\n' )
export status=0

for topology in $topologies; do
if [[ "$all_running" =~ "$topology" ]];
then
    status=$((status+0))
else
    status=$((status+1))
fi
done

if [[ status -eq 0 ]]
then
    echo "OK, $topologies are RUNNING $status"
        exit 0
else
    echo "CRITICAL, $topologies are NOT RUNNING $status"
        exit 2
fi