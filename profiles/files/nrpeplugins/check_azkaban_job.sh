#!/bin/bash
# Check long running or failing job in Azkaban

if [[ "$#" -ne 5 ]]; then
    echo "UNKNOWN You must specify 5 parameters: check type, azkaban project, azkaban flow, warning threshold and critical_threshold."
    exit 3
fi

azk_username=azkaban
azk_password=azkaban
azk_url="http://localhost"

check_type=$1
azk_project=$2
azk_flow=$3
warning_threshold=$4
critical_threshold=$5

session_id=$(curl -s -k -X POST --data "action=login&username=${azk_username}&password=${azk_password}" ${azk_url} | jq -r '.["session.id"]')

case $check_type in
  "duration")
    job_running=$(curl -s -k "${azk_url}/executor?session.id=${session_id}&ajax=getRunning&project=${azk_project}&flow=${azk_flow}" | jq -r '.execIds[0]')

    if [[ "${job_running}" != "null" ]]; then
      job_start=$(curl -s -k "${azk_url}/executor?session.id=${session_id}&ajax=fetchexecflow&execid=${job_running}" | jq -r '.startTime')
      current_timestamp=$(date +%s)
      job_duration=$(((current_timestamp-job_start/1000)))

      if [[ ${job_duration} -ge ${critical_threshold} ]]; then
        echo "CRITICAL ${azk_project}/${azk_flow} is executing for ${job_duration} seconds (threshold: ${critical_threshold}s)."
        exit 2
      elif [[ ${job_duration} -ge ${warning_threshold} ]]; then
        echo "WARNING ${azk_project}/${azk_flow} is executing for ${job_duration} seconds (threshold: ${warning_threshold}s)."
        exit 1
      else
        echo "OK ${azk_project}/${azk_flow} is executing for ${job_duration} seconds  which is below warning and critical thresholds"
        exit 0
      fi
    else
      echo "OK ${azk_project}/${azk_flow} is not running now"
      exit 0
    fi
  ;;
  "failures")
    failures_check_jobs_query_no=$critical_threshold
    last_jobs=( $(curl -s -k "${azk_url}/manager?session.id=${session_id}&ajax=fetchFlowExecutions&project=${azk_project}&flow=${azk_flow}&start=0&length=$((failures_check_jobs_query_no+1))" | jq -r '.executions | map(.status) | join(" ")') )
    if [[ ${last_jobs[0]} == "RUNNING" ]]; then
      unset last_jobs[0]
      running_now=true
    else
      unset last_jobs[3]
      running_now=false
    fi

    failures_count=0
    for job_status in "${last_jobs[@]}"; do
      if [[ "${job_status}" == "FAILED" ]]; then
        (( failures_count++ ))
      fi
    done

    if [[ "${failures_count}" -ge "${critical_threshold}" ]]; then
      echo "CRITICAL ${azk_project}/${azk_flow} failed ${failures_count} times in last ${failures_check_jobs_query_no} finished runs (threshold: ${critical_threshold})"
      exit 2
    elif [[ "${failures_count}" -ge "${warning_threshold}" ]]; then
      echo "WARNING ${azk_project}/${azk_flow} failed ${failures_count} in last ${failures_check_jobs_query_no} finished runs (threshold: ${warning_threshold})"
      exit 1
    else
      echo "OK ${azk_project}/${azk_flow} have not failed in last ${failures_check_jobs_query_no} runs"
      exit 0
    fi
  ;;
  *)
    echo "UNKNOWN First argument must be duration or failures"
    exit 3
  ;;
esac

echo "UNKNOWN We shouldn't be here, run."
exit 3
