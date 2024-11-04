#!/bin/bash

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

prov_filter=("$@")
queue="https://queue.taskcluster.net/v1"

parallel=32

provisioners=$(curl -s -o - "${queue}/provisioners" \
  | grep '"provisionerId' \
  | awk '{print $2}' | grep -o '[^":, \[]*' \
)

function get_task_state()
{
  read -d'\t' -r provisioner workerType workerGroup hostname taskId quarantineUntil <<<"$@"

  printf 'tc_workers,provisionerId=%s,workerType=%s,workerGroup=%s,workerId=%s quarantineUntil=%s,status=%s\n' \
    "$provisioner" "$workerType" "$workerGroup" "$hostname" "$quarantineUntil" \
    $(curl -s -o - "https://queue.taskcluster.net/v1/task/${taskId}/status" \
      | tr '\n' ' ' \
      | ( grep -o "{[^{]*workerId.*${hostname}[^}]*}" || echo "missing" ) \
      | sed -e 's/[\t ]\+/ /g' -e 's/.*state.: .\([^"]*\)",.*/\1/')
}
export -f get_task_state

for provisioner in $provisioners; do
  found=false
  for p in "${prov_filter[@]}"; do
    [[ $provisioner == "$p" ]] || continue
    found=true
    break
  done
  if ! $found; then
    continue
  fi

  workerTypes=$(curl -s -o - "${queue}/provisioners/${provisioner}/worker-types" \
    | grep workerType \
    | awk '{print $2}' | grep -o '[^":, \[]*' \
  )

  for workerType in $workerTypes; do
    if [ $workerType != "gecko-t-osx-1010" ]; then
      continue
    fi

    queryparams="limit=1000"  #&quarantined=true"
    url="${queue}/provisioners/${provisioner}/worker-types/${workerType}/workers?${queryparams}"

    data=""
    continuation=" "
    n=0
    states=""
    while [[ ${#continuation} -gt 0 ]]; do
      read -r continuation <<<$(curl -s -o - "${url}"${continuation} \
        | jq -r '.workers[] | ["'$provisioner'", "'$workerType'", .workerGroup, .workerId, .latestTask?.taskId, .quarantineUntil?] | @tsv' \
        | head -5 \
        | tee \
          >(xargs -P$parallel -L1 -I{} bash -c 'get_task_state {}' >&2)  \
        | grep -o 'continuationToken": "[^\"]*"' | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1\n/' \
        | tee -a tmpdata
      )
echo "[$continuation]"
    done

  done

done
#echo -en "\033[2K\015"
# example: influx line format
# tc_queue_exec,host=telegraf-getting-started,provisionerId=releng-hardware,workerType=gecko-t-win10-64-ux completed=2,failed=2,idle=4,pendingTasks=5,quarantinedWorkers=0,running=6,workers=10 1553621929000000000
