#!/bin/bash
user=$1
instance=$2
searching_for_jobs=$3

if [[ "$instance" != "default" ]]; then
  fmi=" -i ${instance}"
else
  fmi=""
fi

# check if container is up by switching to $user and invoking flink-manager.sh -r
# xargs is used to trim whitespaces
container_status_r=$(su -c "flink-manager.sh${fmi} -r" $user)
is_container_disabled=$(echo "${container_status_r}" | grep "This container is disabled!" -A 1 | tail -1)
if [ ! -z "${is_container_disabled}" ]; then
 echo "Container is disabled: ${is_container_disabled}"
 exit 0
fi

container_status_state=$(echo "${container_status_r}" | grep '^[[:space:]]*State :')
if [ $? -ne 0 ]; then
  echo "Flink Manager can't find container's state, probably it's dead."
  exit 2
fi

container_status=$(echo "${container_status_state}" | cut -d ':' -f 2 | xargs)
if [[ "${container_status}" != "RUNNING" ]]
then
  echo "Flink container is in status ${container_status}"
  exit 2
fi

# get a list of jobs running in Flink's container
jobs_in_container=( $(su -c "flink-manager.sh${fmi} -j running | awk '\$2==\"RUNNING\" {print \$3}'" $user) )

# check if there are any jobs running
if [[ "${#jobs_in_container[@]}" -eq 0 ]]
then
  # check if we're checking jobs presence
  if [[ -z "${searching_for_jobs}" ]]
  then
    echo "Container is running and there are no jobs (but we're not looking for them)."
    exit 0
  else
    echo "Container is running but there are no jobs (and we're looking for them)!"
    exit 2
  fi
else
  if [[ -z "${searching_for_jobs}" ]]
  then
    # if container is running and jobs are started but we're not checking for 'static' jobs it's all ok already
    echo "Container is running and there are jobs (not checking specific jobs)."
    exit 0
  else
    # iterate over jobs we're searching for and check if there were found
    jobs_found=()
    jobs_not_found=()
    IFS=';' read -r -a searching_for_jobs_array <<< "${searching_for_jobs}"
    for searching_for_job in "${searching_for_jobs_array[@]}"
    do
      if [[ ${jobs_in_container[*]} =~ "${searching_for_job}" ]]
      then
        jobs_found+=(${searching_for_job})
      else
        jobs_not_found+=(${searching_for_job})
      fi
    done

    # check if jobs found equals jobs we were searching for
    if [[ "${#jobs_found[@]}" -eq "${#searching_for_jobs_array[@]}" ]]
    then
      echo "Container is running and all jobs were found"
      exit 0
    else
      echo "Container is running but not all jobs were found!"
      echo "Jobs not found:"
      for job_not_found in ${jobs_not_found[@]};do echo "* ${job_not_found}";done
      echo "Jobs found:"
      for job_found in ${jobs_found[@]};do echo "* ${job_found}";done
      exit 2
    fi
  fi
fi

# if we didn't exited yet it means that something wrong happened
echo "I shouldn't get to this part of script - please check me out..."
exit 3
