#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

set -x

date
echo "ECS_CONTAINER_METADATA_URI: ${ECS_CONTAINER_METADATA_URI}"
curl "${ECS_CONTAINER_METADATA_URI}"

container_name=$(curl "${ECS_CONTAINER_METADATA_URI}" | grep "container-name")
echo "container_name: ${container_name}"

# previous hack, to time-spread the reports from multiple cloned collectors
#sleep_time=$(( RANDOM % 300 ))
#echo sleeping $sleep_time
#sleep $sleep_time

filter="${TELEGRAF_INPUT_FILTER}"
if ! [[ "x${filter}" = "x" ]]; then
    filter="--input-filter ${filter}"
    echo "TELEGRAF_INPUT_FILTER: ${TELEGRAF_INPUT_FILTER}"
    echo "filter arg: ${filter}"
fi

# if TELEGRAF_CONFIG is not set, default to telegraf.conf
TELEGRAF_CONFIG=${TELEGRAF_CONFIG:-telegraf.conf}

# TODO: not working for some reason. need to debug.
# set defaults for INTERVAL="300s", MEDIUM_INTERVAL="600s", LONG_INTERVAL="1200s"
export INTERVAL=${INTERVAL:-5m}
export MEDIUM_INTERVAL=${MEDIUM_INTERVAL:-10m}
export LONG_INTERVAL=${LONG_INTERVAL:-20m}

set -x

# basic
/entrypoint.sh telegraf --config "/etc/telegraf/${TELEGRAF_CONFIG}" $@ ${filter}
exit $?

# loop forever
while true; do
  timeout ${TELEGRAF_TIMEOUT_PROC:-12h} /entrypoint.sh telegraf --config "/etc/telegraf/${TELEGRAF_CONFIG}" $@ ${filter}
  echo "telegraf ended"
  echo "Re-run telegraf"
  date
  # if exit code was non-zero, sleep for a bit before trying again
  sleep 30
done
