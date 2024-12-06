#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

provisionerId=aws-provisioner-v1
workerType="${1:-gecko-t-win10-64-gpu}"

echo curl -s -L -o - "https://aws-provisioner.taskcluster.net/v1/state/${workerType}"
curl -s -L -o - "https://aws-provisioner.taskcluster.net/v1/state/${workerType}" \
  | jq -r '(.instances | sort_by(.type, .zone) | map([.type,.zone]) | .[]) | @tsv' \
  | uniq -c \
  | awk '{print "workerType='${workerType}',instanceType="$2",zone="$3" count="$1}'
