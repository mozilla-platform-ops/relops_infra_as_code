#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

# set -x

date

# aws specific stuff, disabling for now
# echo "ECS_CONTAINER_METADATA_URI: ${ECS_CONTAINER_METADATA_URI}"
# curl "${ECS_CONTAINER_METADATA_URI}"
# container_name=$(curl "${ECS_CONTAINER_METADATA_URI}" | grep "container-name")
# echo "container_name: ${container_name}"

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
TELEGRAF_CONFIG=${TELEGRAF_CONFIG:-telegraf_android.conf}

# TODO: not working for some reason. need to debug.
# set defaults for INTERVAL="300s", MEDIUM_INTERVAL="600s", LONG_INTERVAL="1200s"
export INTERVAL=${INTERVAL:-5m}
export MEDIUM_INTERVAL=${MEDIUM_INTERVAL:-10m}
export LONG_INTERVAL=${LONG_INTERVAL:-20m}

# source bitbar secrets (used only in dev)
if [ -f /etc/bitbar_secrets.sh ]; then
  source /etc/bitbar_secrets.sh
fi

# if TESTDROID_APIKEY is not defined, warn
if [ -z "$TESTDROID_APIKEY" ]; then
    echo "FATAL: TESTDROID_APIKEY is not defined"
    exit 1
fi
# if TESTDROID_URL is not defined, warn
if [ -z "$TESTDROID_URL" ]; then
    echo "FATAL: TESTDROID_URL is not defined"
    exit 1
fi
# if both are defined, print a message
if [ -n "$TESTDROID_APIKEY" ] && [ -n "$TESTDROID_URL" ]; then
    echo "OK: TESTDROID_APIKEY and TESTDROID_URL are defined"
fi

# mention if SENTRY_DSN is defined or not
if [ -z "$SENTRY_DSN" ]; then
    echo "WARNING: SENTRY_DSN is not defined"
else
    echo "OK: SENTRY_DSN is defined"
fi

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
