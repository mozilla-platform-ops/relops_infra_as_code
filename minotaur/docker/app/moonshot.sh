#!/bin/bash
# for each moonshot cartridge
#   if ping fails
#     check last task
#     if last task exception or activity > X ago,
#       power cycle from ilo
#     fi
#   fi
# fi
#     
grouped_by_chassis=${1:-true}
if $grouped_by_chassis; then
  echo grouped_by_chassis:"$grouped_by_chassis"
fi

echo "container_tag:$CONTAINER_TAG"
USER=$(id --user --name)
SCRIPT_PATH=$(dirname "$(realpath -s "$0")")

set -o errtrace
trap 'echo "ERR trap from ${FUNCNAME:-MAIN} context."' ERR

run_time_max=${WORKER_RUNNING_MAX:-120 minutes ago}
idle_time_max=${WORKER_IDLE_MAX:-30 minutes ago}

root_url="${TASKCLUSTER_URL:-https://firefox-ci-tc.services.mozilla.com}/api/queue"
export root_url

provisioner=${TASKCLUSTER_PROVISIONER:-releng-hardware}
export provisioner

declare -A queued_tasks
export queued_tasks

declare -A cart_tags
export cart_tags

ilo_user=${ILO_USER:-monitor}
telegraf_url=${INFLUXDB_URL:-https://telegraf.relops.mozops.net}
telegraf_url="${telegraf_url}/write?db=${INFLUXDB_DB:-relops}"
telegraf_user=${INFLUXDB_USER:-relops_wo}
telegraf_password=$(echo "$INFLUXDB_PASSWORD" | grep relops_wo | cut -d\" -f4)


ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
  eval "$(ssh-agent -s)"
  ssh-add - <<<"$MOONSHOT_KEY"
  trap "ssh-agent -k" exit
fi
ssh-add -l


function echo_noping() {
  ip="$1"
  shift
  # tcp ping on ssh(22)
  nmap --host-timeout 10s --max-retries 3 -sn -PA22 "$ip" | grep "Host is up" &>/dev/null \
  || echo "$@"
  # icmp is blocked in lambda docker (unpriv).
  # So we cannot simply ping:
  #ping -q -c1 -w5 ${fqdn} 2>&1 >/dev/null \
  #  || echo "$@"
}


function working() {
  function is_older_than() {
    timestamp="$(echo "$1" | cut -d' ' -f4 | sed -e 's/T/ /')"
    task_timestamp=$(date -u --date="$timestamp" +"%s")
    compare_time=$(date -u --date="$2" +"%s")
    [[ $task_timestamp -lt $compare_time ]]
  }
  function check_queues() {
    provisioner=$1
    workerType=$2
    # use cached value
    if [ -v queued_tasks["${provisioner}"_"${workerType}"] ]; then
      return
    fi
    count_tasks=$(
      wget -q -O - "${root_url}"/v1/pending/"${provisioner}"/"${workerType}" \
      | grep pendingTasks | cut -d: -f2
    )
    queued_tasks[${provisioner}_${workerType}]=$count_tasks
    #echo ${provisioner}_${workerType} ${queued_tasks[${provisioner}_${workerType}]}
  }
  function print_taskname() {
    taskId=$1
    printf "%s" "$(wget -q -O - "${root_url}"/v1/task/"${taskId}" | grep -A6 metadata | grep -o "name.*" | cut -d'"' -f3)"
  }

  worker_url=$1
  taskId=$(wget -q -O - "${worker_url}" | grep 'taskId' | tail -1 | cut -d'"' -f4)
  provisioner=$(echo "$worker_url" | cut -d/ -f8)
  workerType=$(echo "$worker_url" | cut -d/ -f10)
  last_task=$(
    wget -q -O - "${root_url}"/v1/task/"${taskId}"/status \
      | jq -r '.status.runs | .[] | [.state,.started,.resolved] | @tsv'
  )
  last_task_status=$(echo "$last_task" | cut -d' ' -f1)
  last_task_started=$(echo "$last_task" | cut -d' ' -f2)
  last_task_ended=$(echo "$last_task" | cut -d' ' -f3)
  tasks_found=$?
  printf " %s" "$last_task_status"
  if [[ $tasks_found -ne 0 ]]; then
    check_queues "$provisioner" "$workerType"
    if [[ ${queued_tasks[${provisioner}_${workerType}]} -gt 0 ]]; then
      printf " %s" "q[${queued_tasks[${provisioner}_${workerType}]}]"
      return 1
    fi
  else
    if [[ -n $last_task_ended ]]; then
      if is_older_than "$last_task_ended" "${idle_time_max}"; then
        if [[ "$last_task_status" == "exception" ]]; then
          print_taskname "$taskId"
          printf " X"
          return 1
        else
          check_queues "$provisioner" "$workerType"
          if [[ ${queued_tasks[${provisioner}_${workerType}]} -gt 0 ]]; then
            printf "%s" " Q[${queued_tasks[${provisioner}_${workerType}]}]"
            return 1
          fi
          # if no queue, say it isn't working anyway
          #return 1
        fi
      fi
    elif is_older_than "$last_task_started" "${run_time_max}"; then
      printf " S"
      print_taskname "$taskId"
      return 1
    else
      printf " OK"
    fi
  fi
  return 0
}


function ssh_reboot() {
  # ssh_reboot chassis carts [not_autopower]
  function ssh_cmd() {
    for retry in {1..4}; do
      #-oControlPath=/tmp/socket_%r@_h-%p \
      ssh -T \
        -oStrictHostKeyChecking=no \
        -oUserKnownHostsFile="$SCRIPT_PATH"/known_hosts \
        -oServerAliveInterval=5 -oConnectTimeout=10 \
        -oKexAlgorithms=+diffie-hellman-group14-sha1 -oCiphers=+aes128-cbc \
        "${1}" "$2" \
      && break
      printf '.' >&2
      sleep $(( retry * 2 ))
    done
  }
  function is_autopower_on() {
    chassis=$1
    ssh_cmd "$chassis" 'show chassis autopower' | grep 'Chassis Auto-Power: On'
  }
  chassis=$1
  nodes=$2
  if [[ $# -lt 3 ]] || ! is_autopower_on "$chassis"; then
    # this requires the chassis have `set chassis autopower on`
    ssh_cmd "${ilo_user}@$chassis" "reset cartridge power force $nodes"
  else
    nodes=${nodes}N1
    # power off, wait for all off, then on
    ssh_cmd "${ilo_user}@$chassis" "set node power off force $nodes"
    # check power state all down, 5 to 60s
    sleep 5
    for s in {0..10}; do  # 55s max
      sleep "$s"
      nodes_on=$(ssh_cmd "${ilo_user}@$chassis" "show node power $nodes")
      echo "${nodes_on}" | grep -o 'Power State: On' &>/dev/null \
        || break
    done
    ssh_cmd "${ilo_user}@$chassis" "set node power on $nodes"
  fi
}
export -f ssh_reboot
  

function report_metric_each() {
  if [[ $1 == *"="* ]]; then
    tag=","${1}
    type=${2}
  else
    tag=""
    type=${1}
  fi
  shift
  shift
  ids=@
  for id in ${ids[*]}; do
    case $id in
      ''|*[!0-9]*) id=$(echo "$id" | grep -o '[0-9]\+$') ;;
      *) ;;
    esac
    tags=${cart_tags[$id]}
    curl -s --user "$telegraf_user:$telegraf_password" -i -XPOST \
      "$telegraf_url" \
      --data-binary "systemcheck,type=moonshot,event=${type}${tag}${tags}${type}=1" \
      -o /dev/null -w "%{http_code}" >/dev/null
    #echo "systemcheck,type=moonshot,event=${type}${tag}${tags}${type}=1" -o /dev/null -w "%{http_code}" >> ./keep.metrics
  done
}
export -f report_metric_each 


uniq -c -w9 "$SCRIPT_PATH"/workers.txt
declare -A reboots
(
  while IFS= read -r line; do
    echo "[${line}]" >&2
    echo_noping "${line%% *}" "${line}" &
  done <"$SCRIPT_PATH"/workers.txt
  wait
) \
| (
  while IFS=\  read -r ip fqdn worker_id worker_type worker_group worker_url chassis cart I; do
    hostname=${fqdn%%.*}
    echo "noping $hostname" >&2
    cart_tags[$I]=",cart=${cart},chassis=${chassis},host=${hostname},id=$I,workerId=${worker_id},workerType=${worker_type},group=${worker_group} id=${I}i,"
    report_metric_each noping "$I" &
    #(
      if ! working "$worker_url" >&2; then
        report_metric_each reboot "$I" &
        echo "ARGS:$(printf "%s, " "$I" "$chassis" cart:"$cart" fqdn:"$fqdn" ip:"$ip" "$worker_url")" >&2
        if $grouped_by_chassis; then
          echo "reboots[$chassis]+=$cart, (${reboots[$chassis]})" >&2
          reboots[$chassis]+="${cart},"
        else
          echo "REBOOT $chassis $cart"
          echo "reboot $hostname $chassis $cart" >&2
        fi
      fi
    #) &  # was multiprocess and not grouped by chassis, but overloaded lambda memory when 30+ nodes rebooting
  done
  wait
  echo "wait .. are there reboots collected?" >&2
  if $grouped_by_chassis; then
      echo "yes, print them ${#reboots}" >&2
    for i in "${!reboots[@]}"; do
      echo "REBOOT $i ${reboots[$i]}" >&2
      echo "REBOOT $i ${reboots[$i]}"
    done
  fi
) \
| grep REBOOT \
| (
set -xv
  while IFS=\  read -r act chassis carts; do
    echo act="$act" chassis="$chassis" ip=10.49.16.$(( 16 + chassis )) C"${carts%%,}"N1
    ssh_reboot 10.49.16.$(( 16 + chassis )) C"${carts%%,}" &
  done
  echo "... wait during reboots"
  jobs
  wait
)

date
ssh-agent -k
echo "END"
