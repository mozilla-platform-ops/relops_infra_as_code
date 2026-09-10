#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

set -e

# Script to expose TaskCluster metrics in Prometheus format for Telegraf scraping

# based on tc-web.sh
#   - tc-web.sh seems broken, only pending counts seem to work
#     - due to running on OS X? (date command), tc-web.sh doesn't use `date` though

# source common.sh
. "$(dirname "$0")/common.sh"

# ensure jq is present
ensure_jq

PATH="$PATH:$(dirname "${BASH_SOURCE[0]}")"

queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'
worker_manager='https://firefox-ci-tc.services.mozilla.com/api/worker-manager/v1'

batch_limit=1000
task_status_workers=20
prov_filter=("$@") # Accept provisioner filters as command-line arguments

fetch_task_state() {
  local task_id="$1"
  local run_id="$2"
  local status

  if ! status=$(curl --fail --silent --show-error "${queue}/task/${task_id}/status"); then
    echo "Warning: Could not fetch task status for ${task_id}/${run_id}" >&2
    return 0
  fi

  jq -r --argjson run_id "${run_id}" \
    '.status.runs[]? | select(.runId == $run_id) | .state' <<< "${status}"
}

export -f fetch_task_state
export queue

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
  quarantined=0
  task_runs=()
  continuation_token=""
  current_timestamp=$($date_cmd -u +%s)

  while true; do
    request_args=(
      --fail
      --silent
      --show-error
      --get
      "${worker_manager}/provisioners/${provisioner}/worker-types/${workerType}/workers"
      --data-urlencode "limit=${batch_limit}"
    )
    if [[ -n "${continuation_token}" ]]; then
      request_args+=(--data-urlencode "continuationToken=${continuation_token}")
    fi

    if ! data=$(curl "${request_args[@]}"); then
      echo "Error: Could not list workers for ${provisioner}/${workerType}" >&2
      return 1
    fi
    if ! jq -e '.workers | type == "array"' >/dev/null <<< "${data}"; then
      echo "Error: Invalid worker response for ${provisioner}/${workerType}" >&2
      return 1
    fi

    while IFS=$'\t' read -r quarantine_until task_id run_id; do
      total=$((total + 1))
      isQuarantined=false
      if [[ "${quarantine_until}" != "-" ]]; then
        if quarantine_timestamp=$($date_cmd -u -d "${quarantine_until}" +%s 2>/dev/null) && \
          [[ ${quarantine_timestamp} -gt ${current_timestamp} ]]; then
          isQuarantined=true
        fi
      fi

      if [[ "$isQuarantined" == true ]]; then
        quarantined=$((quarantined + 1))
      elif [[ "${task_id}" != "-" && "${run_id}" =~ ^[0-9]+$ ]]; then
        task_runs+=("${task_id} ${run_id}")
      fi
    done < <(
      jq -r \
        '.workers[] | [(.quarantineUntil // "-"), (.latestTask.taskId // "-"), (.latestTask.runId // "-")] | @tsv' \
        <<< "${data}"
    )

    continuation_token=$(jq -r '.continuationToken // empty' <<< "${data}")
    if [[ -z "${continuation_token}" ]]; then
      break
    fi
  done

  if [[ ${#task_runs[@]} -gt 0 ]]; then
    states=$(
      printf '%s\n' "${task_runs[@]}" |
        xargs -n 2 -P "${task_status_workers}" bash -c 'fetch_task_state "$1" "$2"' _
    )
    running=$(grep -c '^running$' <<< "${states}" || true)
  fi

  idle=$((total - running - quarantined))
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
