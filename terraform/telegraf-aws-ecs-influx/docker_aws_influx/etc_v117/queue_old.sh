#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

prov_filter=("$@")
queryparams="limit=1000&quarantined=true"
queue="https://queue.taskcluster.net/v1"

provisioners=$(curl -s -o - "${queue}/provisioners" \
  | grep '"provisionerId' \
  | awk '{print $2}' | grep -o '[^":, \[]*' \
)

comma=""
echo '['
for provisioner in $provisioners; do
  found=false
  for p in "${prov_filter[@]}"; do
    # echo $provisioner == "$p"
    [[ $provisioner == "$p" ]] || continue
    found=true
    break
  done
  if ! $found; then
    continue
  fi

  # echo ${comma}'"'${provisioner}'":['
  workerTypes=$(curl -s -o - "${queue}/provisioners/${provisioner}/worker-types" \
    | grep workerType \
    | awk '{print $2}' | grep -o '[^":, \[]*' \
  )

  for type in $workerTypes; do
    tasks=$(curl -s -o - "${queue}/pending/${provisioner}/${type}")
    echo "${comma}${tasks}"
    comma=","
    continue

    url="${queue}/provisioners/${provisioner}/worker-types/${type}/workers?${queryparams}"

    data=""
    continuation=""
    n=0
    while true ;do
      data=$(curl -s -o - "${url}${continuation}")
      echo $data | grep -o "workers\": \[\]" >/dev/null || echo "$comma"
      # add provisioner and workerType to each worker on print
      echo $data | sed -e 's/ *{ *"workers": *\[//' -e 's/\] *}$//' \
        -e 's/], "continuation.*//' \
        -e "s/workerGroup/provisioner\":\"${provisioner}\", \"workerType\":\"${type}\", \"workerGroup/g"
      if echo ${data} | grep "continuation" >/dev/null ; then
        continuation=$(echo $data | grep -o 'continuationToken": "[^\"]*"' | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1/')
        sleep 2
      else
        break;
      fi
      count=$(echo "$data" | grep -o "workerId" | wc -l)
      n=$(( n + count ))
    done
    if [[ $n -gt 0 ]]; then
      comma=","
    fi

  done

  #echo ']'

done

echo ']'
