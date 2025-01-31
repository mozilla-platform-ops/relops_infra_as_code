#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

# use machine types from
# gcloud compute machine-types list > telegraf/gcp_types.txt
# with content like:
#NAME             ZONE                       CPUS  MEMORY_GB  DEPRECATED
#f1-micro         us-central1-f              1     0.60
#n1-standard-16   europe-west4-b             16    60.00
#n1-standard-16   us-west2-c                 16    60.00

# Check if API_KEY is not set or is empty
if [ -z "${API_KEY}" ]; then
  echo "Error: API_KEY is not defined." >&2
  exit 1
fi

(
since=${1:-24}

# start from $since hours ago
start=$(( $(date +%s) - (60 * 60 * since ) ))

SERVICE_ID="services/6F81-5844-456A"
# SKU for compute engine
# If this SKU changes, re-query:
# curl "https://cloudbilling.googleapis.com/v1/services?key=${API_KEY}" \
#   | grep -i compute

FILTERS="&fields=skus(category(resourceGroup%2CusageType)%2Cdescription%2Cname%2CpricingInfo(effectiveTime%2CpricingExpression(tieredRates(unitPrice(nanos%2Cunits))%2CusageUnitDescription))%2CserviceRegions)"
curl "https://cloudbilling.googleapis.com/v1/${SERVICE_ID}/skus?pageSize=5000${FILTERS}&key=${API_KEY}"



exit
)

false && (
echo "["
for region in us-east-1 us-east-2 us-west-1 us-west-2; do
  aws ec2 describe-spot-price-history --region $region --start-time "${start}" \
    | grep -v -E '^({| *"SpotPriceHistory| *]|})' \
    | sed -Ee 's/"([0-9\.]+)"/\1/'
done \
  | sed -e 's/}$/},/g' -e '$ s/},$/}/'
echo "]"
)
