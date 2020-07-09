#!/bin/bash
pid_file="/var/run/puppetlabs/agent.pid"
agent_process_name="puppet agent"

agent_pid=""
if [[ -a "${pid_file}" ]]; then
  if [[ -r "${pid_file}" ]]; then
    read agent_pid < "${pid_file}"
  fi
fi

if [[ ! -z "${agent_pid}" ]]; then
  if ! ps "${agent_pid}" 2&>/dev/null; then
    echo "There's PID file with ${agent_pid} PID but no process running"
    exit 2
  else
    echo "Puppet Agent is running under PID ${agent_pid}"
    exit 0
  fi
else
  found_pid=$(pgrep -f "${agent_process_name}" -P 1 2>/dev/null)
  found_pid_ec=$?
  if [[ "$found_pid_ec" -eq 0 ]]; then
    echo "Can't read ${pid_file} but Puppet Agent is running under PID ${found_pid} - check it!"
    exit 1
  else
    echo "Can't read ${pid_file} and can't find Puppet Agent process by its name"
    exit 2
  fi
fi

echo "Something's wrong, I shouldn't get here!"
