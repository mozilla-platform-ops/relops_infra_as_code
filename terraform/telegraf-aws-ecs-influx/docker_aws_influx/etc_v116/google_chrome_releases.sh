#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

channels="Stable"
platforms="Windows Android Mac Linux"

function get_state()
{
  channel="$1"
  platform="$2"

  while read -r line ; do
    eval "$line"
    timestamp=${time}000000

    printf 'releases,package=google_chrome,channel=%s,platform=%s version="%s" %s\n' \
      "$channel" "$platform" "$version" $timestamp

  # {"hashes":{"skia":"f13f8690bede09ca97071e9786d68bc0758a24cc","v8":"5bec950c6647873c777f55f1b95ed7ae5d7def73","pdfium":"178b812ec8c7954d782b7822f9d36667542397a0","chromium":"f5a1ee45b812b96c33344099823899840b77b2e0","webrtc":"9863f3d246e2da7a2e1f42bbc5757f6af5ec5682"},"version":"76.0.3809.100","time":1565100000000}
  done <<< "$( \
    curl -s -o -  "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=${platform}&num=3&offset=0" \
      | jq -r -c '.[] | del(.tags) | @sh "channel=\"'$channel'\" platform=\"'$platform'\" time=\(.time) version=\(.version)"'
  )"
}
export -f get_state

for channel in $channels; do
  for platform in $platforms; do
    get_state $channel $platform
  done
done

# example: influx line format
# tc_queue_exec,host=telegraf-getting-started,provisionerId=releng-hardware,workerType=gecko-t-win10-64-ux completed=2,failed=2,idle=4,pendingTasks=5,quarantinedWorkers=0,running=6,workers=10 1553621929000000000

