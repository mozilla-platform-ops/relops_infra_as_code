#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

# do not show the workers. only by provisioner
show_workers=false

prov_filter=("$@")
prov_filter='releng-hardware'
#queue="https://queue.taskcluster.net/v1"
# new urls after TCW Nov 9th 2019:
queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'

provisioners=$(curl -s -o - "${queue}/provisioners" \
  | grep '"provisionerId' \
  | cut -d\" -f4 \
)

queues=""

qcomma=""
comma=""
#echo '{'
$show_workers && echo '"workers":['
#for provisioner in $provisioners; do
for provisioner in "${prov_filter[@]}"; do
  # found=false
  # for p in "${prov_filter[@]}"; do
  #   # echo $provisioner == "$p"
  #   [[ $provisioner == "$p" ]] || continue
  #   found=true
  #   break
  # done
  # if ! $found; then
  #   continue
  # fi

  # echo ${comma}'"'${provisioner}'":['
  workerTypes=$(curl -s -o - "${queue}/provisioners/${provisioner}/worker-types" \
    | grep workerType \
    | cut -d\" -f4 \
  )

  for type in $workerTypes; do
    #if [ $type != "gecko-t-osx-1010" ]; then
    #  continue
    #fi
    #queryparams="limit=1000"  #&${quarantined}"
    queryparams="limit=1000"  #&quarantined=true"
    url="${queue}/provisioners/${provisioner}/worker-types/${type}/workers?${queryparams}"

    data=""
    continuation=""
    n=0
    quarantined=0
    states=""
    while true ;do
      data=$(curl -s -o - "${url}${continuation}")
      $show_workers && (echo $data | grep -o "workers\": \[\]" >/dev/null || echo "$comma")
      # add provisioner and workerType to each worker on print
      # { "provisioner":"releng-hardware",
      #   "workerType":"gecko-t-osx-1010",
      #   "workerGroup": "scl3",
      #   "workerId": "t-yosemite-r7-0065",
      #   "firstClaim": "2018-06-18T13:51:55.466Z",
      #   "latestTask": { "taskId": "HDbBAeGjSVKN0Dwai4QaOA", "runId": 0 },
      #   "quarantineUntil": "3017-10-19T14:19:34.168Z"
      # }

      if $show_workers; then
        echo $data | sed -e 's/ *{ *"workers": *\[//' -e 's/\] *}$//' \
          -e 's/], "continuation.*//' \
          -e "s/workerGroup/provisioner\":\"${provisioner}\", \"workerType\":\"${type}\", \"workerGroup/g"
      fi
      count=$(echo "$data" | grep -o "workerId" | wc -l)

      qcount=$(echo "$data" | sed -e 's/}, *{/},\n{/g' | grep -v scl3 | grep -o "quarantineUntil" | wc -l)
      n=$(( n + count ))
      quarantined=$(( quarantined + qcount ))
      workers=$(echo "$data" | jq -r '.workers[] | [.workerGroup, .workerId, .latestTask?.taskId] | @tsv')

      states="${states}"$(
      (
      while read -r dc hostname taskId ; do
        wget -o /dev/null -q -O - ${queue}/task/${taskId}/status \
            | jq -r '.status.runs | .[] | [.state] | @tsv' &
            #| jq -r '.status.runs | .[] | [.state, .started, .resolved] | @tsv' &
      done <<< "$workers"
      wait
      ) | sort)
		    #| tr '\n' ' ' | grep -o "{[^{]*workerId.*${hostname}[^}]*}" \
		    #| sed -e 's/[\t ]\+/ /g' -e 's/.*state.: .\([^"]*\)",.*started": "\([0-9:\.TZ\-]\+\)",\?\( "resolved":\( \)"\([0-9:\.TZ\-]\+\)"\)\?.*/\1 \2\4\5/' \
            #        | cut -d' ' -f1 &

      if echo ${data} | grep "continuation" >/dev/null ; then
        continuation=$(echo $data | grep -o 'continuationToken": "[^\"]*"' | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1/')
        sleep 1
      else
        break;
      fi
    done
    if [[ $n -gt 0 ]]; then
      comma=","
    fi

    running=$(echo "$states" | sort | grep running | wc -l)
    idle=$(( n - running - quarantined ))
    states=$(echo "$states" | sort | uniq -c | awk '{print "\""$2"\": "$1","}' | tr '\n' ' ')
    # add to counts, queue
    tasks=$(curl -s -o - "${queue}/pending/${provisioner}/${type}")
    tasks=$(echo "$tasks" | sed -e 's/pendingTasks/workers":'${n}',"pendingTasks/')
    tasks=$(echo "$tasks" | sed -e 's/"pendingTasks/'"${states}"'"pendingTasks/')
    tasks=$(echo "$tasks" | sed -e 's/pendingTasks/idle":'"${idle}"',"pendingTasks/')
    tasks=$(echo "$tasks" | sed -e 's/pendingTasks/quarantined":'${quarantined}',"pendingTasks/')
    queues="${queues}${qcomma}${tasks}"
    qcomma=","
    #continue

  done

  #echo ']'

done

$show_workers && echo '],'
#echo '"queues":['
echo '['
echo "$queues"
echo "$queues" > $(dirname ${BASH_SOURCE[0]})/queue2_${prov_filter// /_/}.log 2>/dev/null

echo ']'
#echo '}'
