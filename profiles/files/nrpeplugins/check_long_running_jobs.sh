#!/bin/bash
# Check long running Export jobs

export CURRENT_MS=$(($(date +%s%N)/1000000))
export RUNNING_JOBS=0
export LONG_RUNNING_JOBS=0
export WARN_JOBS_COUNT=10
export CRIT_JOBS_COUNT=20
export CRITICAL_RUNNING_MS=9000000
while read LINE;
do
        export CREATION_TIME=$(echo "$LINE" | awk -F',' '{print $1}');
        export STATUS=$(echo "$LINE" | awk -F',' '{print $2}');
        export CUSTOMER_ID=$(echo "$LINE" | awk -F',' '{print $3}');
        export JOB_TYPE=$(echo "$LINE" | awk -F',' '{print $4}');
        if [ -z $CREATION_TIME ] ; then
                export RUNNING_JOBS=0
#               echo "OK There are $RUNNING_JOBS running jobs"
        else
                export CREATION_ELAPSED_MS=$((CURRENT_MS - CREATION_TIME))
#                echo "CURRENT_MS: $CURRENT_MS; CREATION_TIME: $CREATION_TIME; START_TIME: $START_TIME; STATUS: $STATUS; CUSTOMER_ID: $CUSTOMER_ID; JOB_TYPE: $JOB_TYPE; CREATION_ELAPSED_MS: $CREATION_ELAPSED_MS"
                if [ "$CREATION_ELAPSED_MS" -ge "$CRITICAL_RUNNING_MS" ]; then
                   if [ "$CUSTOMER_ID" -ne "30014" ] && [ "$CUSTOMER_ID" -ne "0" ] && [[ ! $JOB_TYPE =~ .*SWEEPER.* ]] && [[ "$JOB_TYPE" != "SC_MONTHLY" ]] && [ "$CUSTOMER_ID" -ne "8827" ] && [ "$CUSTOMER_ID" -ne "13109" ]; then
                        export LONG_RUNNING_JOBS=$((LONG_RUNNING_JOBS + 1))
                   fi
                        export RUNNING_JOBS=$((RUNNING_JOBS + 1))
                else
                        export RUNNING_JOBS=$((RUNNING_JOBS + 1))
                fi
        fi
done < <(curl -s -k 'http://localhost:8079/ui/v2/jobs?pageNumber=0&pageSize=1000&order=asc&sortColumn=id&statuses=CREATED,BLOCKED,PREPARING,RUNNING,UNKNOWN'| jq -r '.jobs | map([ (.creationTime | tostring),.status,.customerId,.type]| join(",")) | join("\n")')

#       done < <(curl -s -k 'http://localhost:8079/ui/v2/jobs?pageNumber=0&pageSize=5&order=asc&sortColumn=id&statuses=CREATED,BLOCKED,PREPARING,RUNNING,UNKNOWN'| jq -r '.jobs | map([.creationTime | tostring,.startTime | tostring,.status,.customerId,.type]| join(",")) | join("\n")')
#done < <(cat jobs.json | jq -r '.jobs | map([.startTime,.endTime,.status]| join(",")) | join("\n")')

if [ "$LONG_RUNNING_JOBS" -lt "$WARN_JOBS_COUNT" ]; then
        echo "OK There are $RUNNING_JOBS running jobs"
        exit 0
elif [ "$LONG_RUNNING_JOBS" -ge "$WARN_JOBS_COUNT" ] && [ "$LONG_RUNNING_JOBS" -lt "$CRIT_JOBS_COUNT" ]; then
        echo "WARNING There are $LONG_RUNNING_JOBS running jobs, RUNNING more than $CRITICAL_RUNNING_MS milliseconds"
        exit 1
else
        echo "CRITICAL There are $LONG_RUNNING_JOBS running jobs, RUNNING more than $CRITICAL_RUNNING_MS milliseconds"
        exit 2
fi
