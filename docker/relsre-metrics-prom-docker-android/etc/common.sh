#!/usr/bin/env bash

# shellcheck disable=SC2034


#
# shared variables
#

# TODO: uppercase?
# development
#metric_prefix="relsre_" # Static prefix for all metrics
#
# prod, nothing
metric_prefix="" # Static prefix for all metrics


#
# shared functions
#

# write a function that ensure the `jq` binary is present
function ensure_jq() {
    if ! command -v jq &> /dev/null; then
        echo "jq could not be found, please install it"
        exit 1
    fi
}

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
