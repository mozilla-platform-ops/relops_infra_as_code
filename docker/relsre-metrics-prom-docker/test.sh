#!/usr/bin/env bash

# set -e
#set -x

# run `TELEGRAF_CONFIG='telegraf-aerickson-testing.conf' ./docker_run` in another window first

if curl -q http://localhost:9273/metrics 2>/dev/null | grep 'fc_ceph_df_usage_percent'; then
  # here doc for ascii art
  echo ""
  cat << "EOF"
  eeeee e   e eeee eeee eeee eeeee eeeee
  8   " 8   8 8  8 8  8 8    8   " 8   "
  8eeee 8e  8 8e   8e   8eee 8eeee 8eeee
    88 88  8 88   88   88      88    88
  8ee88 88ee8 88e8 88e8 88ee 8ee88 8ee88

EOF
else
  echo ""
  cat << "EOF"
  __       _ _
 / _| __ _(_) |
| |_ / _` | | |
|  _| (_| | | |
|_|  \__,_|_|_|

EOF
fi

