#!/bin/bash
# Check long running camus job

export SESSION_ID=$(curl -s -k -X POST --data "action=login&username=azkaban&password=azkaban" http://localhost:80 | jq -r '.["session.id"]')
export RUNNING_ID=$(curl -s -k --data "session.id=${SESSION_ID}&ajax=getRunning&project=batch&flow=camus" http://localhost:80/executor | jq -r '.execIds[0]')

if [[ "$RUNNING_ID" != "null" ]];
then
  START_TIME=$(curl -s -k --data "session.id=${SESSION_ID}&ajax=fetchexecflow&execid=${RUNNING_ID}" http://localhost:80/executor | jq -r '.startTime')
  END_TIME=$(curl -s -k --data "session.id=${SESSION_ID}&ajax=fetchexecflow&execid=${RUNNING_ID}" http://localhost:80/executor | jq -r '.endTime')
else
  echo "OK There is no running Camus job"
  exit 0
fi

# echo "SESSION_ID: $SESSION_ID RUNNING_ID: $RUNNING_ID START_TIME: $START_TIME END_TIME: $END_TIME "

if [[ "$END_TIME" == "-1" ]];
then
  CURRENT_TIME=$(date +%s%3N)
  EXEC_TIME=$((CURRENT_TIME-START_TIME))
  DURATION=$((EXEC_TIME/1000))
  if [ "$DURATION" -lt "300" ]; then
    echo "OK Camus Job $RUNNING_ID running $DURATION seconds"
    exit 0
  elif [ "$DURATION" -gt "300" ] && [ "$DURATION" -lt "3600" ]; then
    echo "WARNING Camus Job $RUNNING_ID running $DURATION seconds"
    exit 1
  else
    echo "CRITICAL Camus Job $RUNNING_ID running $DURATION seconds"
    exit 2
  fi
fi