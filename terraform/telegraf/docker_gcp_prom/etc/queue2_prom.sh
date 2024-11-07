#!/bin/bash

# Disable shellcheck warnings
# shellcheck disable=all

# Script to pull taskcluster worker stats and output in Prometheus format for Telegraf

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

# Variables
show_workers=false
prov_filter=('releng-hardware')
queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'

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

    # Output in Prometheus format
    echo "# HELP taskcluster_workers_total Number of workers."
    echo "# TYPE taskcluster_workers_total gauge"
    echo "taskcluster_workers_total{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${n}"

    echo "# HELP taskcluster_running_workers Number of workers in running state."
    echo "# TYPE taskcluster_running_workers gauge"
    echo "taskcluster_running_workers{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${running}"

    echo "# HELP taskcluster_idle_workers Number of idle workers."
    echo "# TYPE taskcluster_idle_workers gauge"
    echo "taskcluster_idle_workers{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${idle}"

    echo "# HELP taskcluster_quarantined_workers Number of quarantined workers."
    echo "# TYPE taskcluster_quarantined_workers gauge"
    echo "taskcluster_quarantined_workers{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${quarantined}"

    echo "# HELP taskcluster_completed_tasks Number of tasks in completed state."
    echo "# TYPE taskcluster_completed_tasks gauge"
    echo "taskcluster_completed_tasks{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${completed}"

    echo "# HELP taskcluster_exception_tasks Number of tasks in exception state."
    echo "# TYPE taskcluster_exception_tasks gauge"
    echo "taskcluster_exception_tasks{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${exception}"

    echo "# HELP taskcluster_pending_tasks Number of pending tasks."
    echo "# TYPE taskcluster_pending_tasks gauge"
    echo "taskcluster_pending_tasks{provisioner=\"${provisioner}\", workerType=\"${type}\"} ${pendingTasks}"
  done
done