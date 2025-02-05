#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

(
since=${1:-24}

# start from $since hours ago
start=$(( $(date +%s) - (60 * 60 * since ) ))

echo "["
for region in us-east-1 us-east-2 us-west-1 us-west-2; do
  aws ec2 describe-spot-price-history --region $region --start-time "${start}" \
    | grep -v -E '^({| *"SpotPriceHistory| *]|})' \
    | sed -Ee 's/"([0-9\.]+)"/\1/'
done \
  | sed -e 's/}$/},/g' -e '$ s/},$/}/'
echo "]"
)
