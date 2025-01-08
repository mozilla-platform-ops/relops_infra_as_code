#!/bin/bash

# Disable shellcheck for this script
# shellcheck disable=all

set -e

# source common.sh
. "$(dirname "$0")/common.sh"

# Print the Prometheus HELP and TYPE information once
cat <<EOF
# HELP ${metric_prefix}chrome_release_version Version of Chrome releases
# TYPE ${metric_prefix}chrome_release_version gauge
EOF

channels="Stable"
platforms="Windows Android Mac Linux"

function get_state()
{
  channel="$1"
  platform="$2"

  while read -r line ; do
    eval "$line"
    timestamp=${time}000000000

    # Output the Prometheus metric line with the version as a label
    printf "${metric_prefix}chrome_release_version{channel=\"%s\",platform=\"%s\",version=\"%s\"} 1 %s\n" \
      "$channel" "$platform" "$version" "$timestamp"

  done <<< "$( \
    curl -s -o - "https://chromiumdash.appspot.com/fetch_releases?channel=${channel}&platform=${platform}&num=3&offset=0" \
      | jq -r -c '.[] | del(.tags) | @sh "channel=\"'$channel'\" platform=\"'$platform'\" time=\(.time) version=\(.version)"'
  )"
}
export -f get_state

# Output metrics
for channel in $channels; do
  for platform in $platforms; do
    get_state $channel $platform
  done
done
