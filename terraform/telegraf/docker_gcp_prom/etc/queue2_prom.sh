#!/bin/bash

# Base URL for Taskcluster queue
queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'

# Filter for specific provisioners if specified
prov_filter=("$@")

# Current timestamp in nanoseconds for Prometheus format
timestamp=$(date +%s%N)

# Function to output metrics in Telegraf Prometheus serializer format
function output_metric {
  local metric_name=$1
  local tags=$2
  local fields=$3
  local timestamp=$4
  echo "${metric_name},${tags} ${fields} ${timestamp}"
}

# Loop over each provisioner specified in prov_filter
for provisioner in "${prov_filter[@]}"; do
  # Fetch worker types for the current provisioner
  workerTypes=$(curl -s "${queue}/provisioners/${provisioner}/worker-types" \
    | grep workerType | awk '{print $2}' | grep -o '[^":, \[]\+')

  # Loop over each worker type
  for type in $workerTypes; do
    # Initialize counts for workers and quarantined workers
    n=0
    quarantined=0
    queryparams="limit=1000"
    url="${queue}/provisioners/${provisioner}/worker-types/${type}/workers?${queryparams}"

    # Continuation loop to fetch all workers
    continuation=""
    while true; do
      data=$(curl -s "${url}${continuation}")
      count=$(echo "$data" | grep -o "workerId" | wc -l)
      qcount=$(echo "$data" | sed -e 's/}, *{/},\n{/g' | grep -v scl3 | grep -o "quarantineUntil" | wc -l)

      # Update counters
      n=$(( n + count ))
      quarantined=$(( quarantined + qcount ))

      # Check for continuation
      if echo "${data}" | grep "continuation" >/dev/null; then
        continuation=$(echo "$data" | grep -o 'continuationToken": "[^"]*"' \
          | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1/')
        sleep 2
      else
        break
      fi
    done

    # Fetch pending tasks for this worker type
    tasks=$(curl -s "${queue}/pending/${provisioner}/${type}" | grep -o '"pendingTasks":[0-9]*' | awk -F: '{print $2}')
    tasks=${tasks:-0}

    # Define tags and fields in Telegraf Prometheus serializer format
    tags="provisioner=${provisioner},worker_type=${type}"
    fields="worker_count=${n},quarantined_workers=${quarantined},pending_tasks=${tasks}"

    # Output metrics in Telegraf Prometheus serializer format
    output_metric "taskcluster_workers" "${tags}" "${fields}" "${timestamp}"
  done
done