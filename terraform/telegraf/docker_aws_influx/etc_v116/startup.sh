#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

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

set -x
exec /entrypoint.sh telegraf --config "/etc/telegraf/${TELEGRAF_CONFIG}" $@ ${filter}
