#!/bin/bash

# Base URL for Taskcluster queue
queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'

# Filter for specific provisioners if specified
prov_filter=("$@")

# Function to output Prometheus-compatible metrics
function output_metric {
  local metric_name=$1
  local labels=$2
  local value=$3
  echo "${metric_name}{${labels}} ${value}"
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

    # Define labels for this metric output in Prometheus format
    labels="provisioner=\"${provisioner}\",worker_type=\"${type}\""

    # Output Prometheus-compatible metrics in the required format
    output_metric "worker_count" "${labels}" "${n}"
    output_metric "quarantined_workers" "${labels}" "${quarantined}"
    output_metric "pending_tasks" "${labels}" "${tasks}"

  done
done