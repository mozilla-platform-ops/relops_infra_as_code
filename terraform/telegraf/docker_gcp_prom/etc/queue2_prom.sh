#!/bin/bash

# Disable shellcheck warnings
# shellcheck disable=all

set -e

# source common.sh
. "$(dirname "$0")/common.sh"
# ensure jq is present
ensure_jq

# Script to pull taskcluster worker stats and output in Prometheus format for Telegraf

PATH="$PATH:$(dirname $0)"

# Argument checking
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <provisioner1> [<provisioner2> ...]"
  echo "Please specify at least one provisioner filter."
  exit 1
fi

# Variables
show_workers=false
prov_filter=("$@") # Provisioner filters from command line
queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'
# TODO: load from common.sh or similar

# Print HELP and TYPE comments once per metric
echo "# HELP ${metric_prefix}workers_total Number of workers."
echo "# TYPE ${metric_prefix}workers_total gauge"

echo "# HELP ${metric_prefix}running_workers Number of workers in running state."
echo "# TYPE ${metric_prefix}running_workers gauge"

echo "# HELP ${metric_prefix}idle_workers Number of idle workers."
echo "# TYPE ${metric_prefix}idle_workers gauge"

echo "# HELP ${metric_prefix}quarantined_workers Number of quarantined workers."
echo "# TYPE ${metric_prefix}quarantined_workers gauge"

echo "# HELP ${metric_prefix}completed_tasks Number of tasks in completed state."
echo "# TYPE ${metric_prefix}completed_tasks gauge"

echo "# HELP ${metric_prefix}exception_tasks Number of tasks in exception state."
echo "# TYPE ${metric_prefix}exception_tasks gauge"

echo "# HELP ${metric_prefix}pending_tasks Number of pending tasks."
echo "# TYPE ${metric_prefix}pending_tasks gauge"

# Collect provisioners
provisioners=$(curl -s -o - "${queue}/provisioners" | grep '"provisionerId' | cut -d\" -f4)
queues=""

for provisioner in "${prov_filter[@]}"; do
  workerTypes=$(curl -s -o - "${queue}/provisioners/${provisioner}/worker-types" | grep workerType | cut -d\" -f4)

  for type in $workerTypes; do
    queryparams="limit=1000"
    url="${queue}/provisioners/${provisioner}/worker-types/${type}/workers?${queryparams}"

    n=0
    quarantined=0
    states=""

    # Define labels for Prometheus metrics, including taskQueueId
    labels="{provisioner=\"${provisioner}\", workerType=\"${type}\"}"
    #
    # add taskQueueId to labels
    # taskQueueId="${provisioner}/${type}"
    # labels="{provisioner=\"${provisioner}\", workerType=\"${type}\", taskQueueId=\"${taskQueueId}\"}"

    while true; do
      data=$(curl -s -o - "${url}${continuation}")
      count=$(echo "$data" | grep -o "workerId" | wc -l)
      qcount=$(echo "$data" | sed -e 's/}, *{/},\n{/g' | grep -v scl3 | grep -o "quarantineUntil" | wc -l)
      n=$((n + count))
      quarantined=$((quarantined + qcount))
      workers=$(echo "$data" | jq -r '.workers[] | [.workerGroup, .workerId, .latestTask?.taskId] | @tsv')

      # Collect states of each worker's tasks
      states="${states}"$(
        (
          while read -r dc hostname taskId; do
            wget -o /dev/null -q -O - ${queue}/task/${taskId}/status | jq -r '.status.runs | .[] | [.state] | @tsv' &
          done <<< "$workers"
          wait
        ) | sort)

      # Check for continuation token
      if echo "$data" | grep "continuation" >/dev/null; then
        continuation=$(echo "$data" | grep -o 'continuationToken": "[^\"]*"' | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1/')
        sleep 1
      else
        break
      fi
    done

    # Summarize state counts
    running=$(echo "$states" | sort | grep running | wc -l)
    idle=$((n - running - quarantined))
    completed=$(echo "$states" | sort | grep completed | wc -l)
    exception=$(echo "$states" | sort | grep exception | wc -l)

    # Get pending tasks count
    tasks=$(curl -s -o - "${queue}/pending/${provisioner}/${type}")
    pendingTasks=$(echo "$tasks" | jq -r '.pendingTasks')

    # Output metric values with prefix and labels
    echo "${metric_prefix}workers_total${labels} ${n}"
    echo "${metric_prefix}running_workers${labels} ${running}"
    echo "${metric_prefix}idle_workers${labels} ${idle}"
    echo "${metric_prefix}quarantined_workers${labels} ${quarantined}"
    echo "${metric_prefix}completed_tasks${labels} ${completed}"
    echo "${metric_prefix}exception_tasks${labels} ${exception}"
    echo "${metric_prefix}pending_tasks${labels} ${pendingTasks}"
  done
done
