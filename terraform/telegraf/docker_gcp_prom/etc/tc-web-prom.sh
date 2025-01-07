#!/bin/bash

# Script to expose TaskCluster metrics in Prometheus format for Telegraf scraping

# based on tc-web.sh
#   - tc-web.sh seems broken, only pending counts seem to work
#     - due to running on OS X? (date command), tc-web.sh doesn't use `date` though

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

# source common.sh
. "$(dirname "$0")/common.sh"

PATH="$PATH:$(dirname "${BASH_SOURCE[0]}")"

queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'
url='https://firefox-ci-tc.services.mozilla.com/graphql'

batch_limit=1000
prov_filter=("$@") # Accept provisioner filters as command-line arguments

# Function to fetch worker type details
fetch_worker_data() {
  local provisioner="$1"
  local workerType="$2"

  # Determine the appropriate date command
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -x "/opt/homebrew/opt/coreutils/libexec/gnubin/date" ]]; then
      date_cmd="/opt/homebrew/opt/coreutils/libexec/gnubin/date"
    else
      echo "Error: GNU date not found at /opt/homebrew/opt/coreutils/libexec/gnubin/date. Install coreutils via Homebrew." >&2
      exit 1
    fi
  else
    date_cmd="date"
  fi

  total=0
  running=0
  idle=0
  quarantined=0

  continuation='"limit":'"${batch_limit}"
  while true; do
    # Fetch data from the API
    data=$(curl -s -X POST "${url}" \
      -H 'content-type: application/json' \
      --data '{"operationName":"ViewWorkers","variables":{"provisionerId":"'"${provisioner}"'","workerType":"'"${workerType}"'","workersConnection":{'$continuation'}},"query":"query ViewWorkers($provisionerId: String!, $workerType: String!, $workersConnection: PageConnection, $quarantined: Boolean) {\n  workers(provisionerId: $provisionerId, workerType: $workerType, connection: $workersConnection, isQuarantined: $quarantined) {\n    pageInfo {\n      hasNextPage\n      hasPreviousPage\n      cursor\n      previousCursor\n      nextCursor\n      __typename\n    }\n    edges {\n      node {\n        latestTask {\n          run {\n            workerGroup\n            workerId\n            taskId\n            runId\n            started\n            resolved\n            state\n            __typename\n          }\n          __typename\n        }\n        workerGroup\n  workerId\n        quarantineUntil\n        }\n      }\n    }\n  }\n"}'
    )

    # Log the raw API response for debugging
    # echo "API Response for provisioner=${provisioner}, workerType=${workerType}: $data" >&2

    # Check for valid data
    if [[ -z "$data" || "$data" == "null" ]]; then
      echo "Error: No data returned for provisioner=${provisioner}, workerType=${workerType}" >&2
      break
    fi

    workers=$(echo "$data" | jq -c '.data.workers.edges[]?.node' 2>/dev/null)
    if [[ -z "$workers" ]]; then
      echo "No workers found for provisioner=${provisioner}, workerType=${workerType}" >&2
      break
    fi

    # Process each worker
    for worker in $workers; do
      quarantineUntil=$(echo "$worker" | jq -r '.quarantineUntil')
      workerId=$(echo "$worker" | jq -r '.workerId')
      workerGroup=$(echo "$worker" | jq -r '.workerGroup')
      # parsing state is not working yet, not selecting the correct element.
      # state=$(echo "$worker" | jq -r '.latestTask.state // "IDLE"')

      # Debugging: Log quarantineUntil value
      # echo "quarantineUntil: $quarantineUntil, state: $state" >&2

      # Check if quarantineUntil is in the future
      isQuarantined=false
      if [[ "$quarantineUntil" != "null" ]]; then
        # Strip fractional seconds and remove 'Z'
        sanitizedQuarantineUntil=$(echo "$quarantineUntil" | sed -E 's/\.[0-9]+//; s/Z//')
        quarantineTimestamp=$($date_cmd -u -d "$sanitizedQuarantineUntil" +%s 2>/dev/null)
        currentTimestamp=$($date_cmd -u +%s)

        if [[ $quarantineTimestamp -gt $currentTimestamp ]]; then
          isQuarantined=true
        fi
      fi

      # Calculate running, idle, and quarantined workers
      if [[ "$isQuarantined" == true ]]; then
        ((quarantined++))
      elif [[ "$worker" == *"RUNNING"* ]]; then
        ((running++))
      else
        ((idle++))
      fi
      ((total++))
    done

    # Check if there are more pages of data
    hasNextPage=$(echo "$data" | jq -r '.data.workers.pageInfo.hasNextPage' 2>/dev/null)
    if [[ "$hasNextPage" != "true" ]]; then
      break
    fi

    # Update continuation token
    continuation='"cursor":"'"$(echo "$data" | jq -r '.data.workers.pageInfo.cursor' 2>/dev/null)"'","limit":'"${batch_limit}"
  done

  echo "$total" "$running" "$idle" "$quarantined"
}

# Fetch provisioners
provisioners=$(curl -s "${queue}/provisioners" | jq -r '.provisioners[]?.provisionerId' 2>/dev/null)

# Apply provisioner filters if provided
if [[ "${#prov_filter[@]}" -gt 0 ]]; then
  provisioners=$(echo "$provisioners" | grep -Fxf <(printf "%s\n" "${prov_filter[@]}"))
fi

# Check if provisioners list is empty
if [[ -z "$provisioners" ]]; then
  echo "Error: No provisioners found." >&2
  exit 1
fi

# Generate Prometheus metrics
{
  echo "# HELP ${metric_prefix}taskcluster_workers_total Total number of workers."
  echo "# TYPE ${metric_prefix}taskcluster_workers_total gauge"
  echo "# HELP ${metric_prefix}taskcluster_running_workers Total number of running workers."
  echo "# TYPE ${metric_prefix}taskcluster_running_workers gauge"
  echo "# HELP ${metric_prefix}taskcluster_idle_workers Total number of idle workers."
  echo "# TYPE ${metric_prefix}taskcluster_idle_workers gauge"
  echo "# HELP ${metric_prefix}taskcluster_quarantined_workers Total number of quarantined workers."
  echo "# TYPE ${metric_prefix}taskcluster_quarantined_workers gauge"
  echo "# HELP ${metric_prefix}taskcluster_pending_tasks Total number of pending tasks."
  echo "# TYPE ${metric_prefix}taskcluster_pending_tasks gauge"

  for provisioner in $provisioners; do
    workerTypes=$(curl -s "${queue}/provisioners/${provisioner}/worker-types" | jq -r '.workerTypes[]?.workerType' 2>/dev/null)

    # Check if worker types list is empty
    if [[ -z "$workerTypes" ]]; then
      echo "Warning: No worker types found for provisioner=${provisioner}" >&2
      continue
    fi

    for workerType in $workerTypes; do
      read -r total running idle quarantined <<< "$(fetch_worker_data "$provisioner" "$workerType")"
      pendingTasks=$(curl -s "${queue}/pending/${provisioner}/${workerType}" | jq -r '.pendingTasks // 0' 2>/dev/null)

      # Ensure all metrics are printed with defaults if unset
      total=${total:-0}
      running=${running:-0}
      idle=${idle:-0}
      quarantined=${quarantined:-0}
      pendingTasks=${pendingTasks:-0}

      echo "${metric_prefix}taskcluster_workers_total{provisionerId=\"${provisioner}\",workerType=\"${workerType}\"} ${total}"
      echo "${metric_prefix}taskcluster_running_workers{provisionerId=\"${provisioner}\",workerType=\"${workerType}\"} ${running}"
      echo "${metric_prefix}taskcluster_idle_workers{provisionerId=\"${provisioner}\",workerType=\"${workerType}\"} ${idle}"
      echo "${metric_prefix}taskcluster_quarantined_workers{provisionerId=\"${provisioner}\",workerType=\"${workerType}\"} ${quarantined}"
      echo "${metric_prefix}taskcluster_pending_tasks{provisionerId=\"${provisioner}\",workerType=\"${workerType}\"} ${pendingTasks}"
    done
  done
}
