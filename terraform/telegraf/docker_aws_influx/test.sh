#!/usr/bin/env bash

set -e
#set -x

# run `TELEGRAF_CONFIG='telegraf-aerickson-testing.conf' ./docker_run` in another window first

curl -q http://localhost:9273/metrics 2>/dev/null \
  | grep 'fc_ceph_df_usage_percent{crush_type="osd",host="10c073ffaf06"} 35.85032'


echo "success"
