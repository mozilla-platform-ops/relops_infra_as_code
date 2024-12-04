#!/bin/bash

# shellcheck disable=all

# expects environment vars:
# TASKCLUSTER_CLIENT_ID
# TASKCLUSTER_ACCESS_TOKEN
# TASKCLUSTER_ROOT_URL


source=releng-hardware/gecko-t-linux-talos-1804
while true; do
    for target in releng-hardware/gecko-t-linux-talos-g4dn-{,2,4,8,16}xlarge; do
        pending=$(./pending.py "$target" 2>error.log ) \
            || {
            echo "Failed checking pending for $target"
        }
        if grep "AuthenticationFailed" error.log; then
            echo -en "AuthenticationFailed\n\007"
            sleep 30
        fi
        echo $target "$pending"
        if [[ "$pending" -lt 20 ]] && [[ ${#pending} -ne 0 ]]; then
            timeout 30s ./stage.py "$source" "$target" 30 \
                || echo -en "Failed to stage tasks to $target\n\007"
        fi
    done
    sleep 600
done

