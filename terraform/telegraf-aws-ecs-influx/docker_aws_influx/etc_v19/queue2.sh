#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

set +e

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

# do not show the workers. only by provisioner
show_workers=false

prov_filter=("$@")
#prov_filter='releng-hardware'
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
#$show_workers && echo '"workers":['
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
    # if [ $type != "gecko-t-osx-1015-r8-staging" ]; then
    #   continue
    # fi
    #queryparams="limit=1000"  #&${quarantined}"
    queryparams="limit=1000"  #&quarantined=true"
    url="${queue}/provisioners/${provisioner}/worker-types/${type}/workers?${queryparams}"

    data=""
    continuation=""
    n=0
    quarantined=0
    states=""
    while true; do
        data=$(curl -s -o - "${url}${continuation}")

      #if $show_workers; then
      #  echo $data | sed -e 's/ *{ *"workers": *\[//' -e 's/\] *}$//' \
      #    -e 's/], "continuation.*//' \
      #    -e "s/workerGroup/provisioner\":\"${provisioner}\", \"workerType\":\"${type}\", \"workerGroup/g"
      #fi
      count=$(echo "$data" | grep -o "workerId" | wc -l)
      qcount=$(echo "$data" | sed -e 's/}, *{/},\n{/g' | grep -v scl3 | grep -o "quarantineUntil" | wc -l)
      n=$(( n + count ))
      quarantined=$(( quarantined + qcount ))
      workers=$(echo "$data" | tr -d '\n' | sed -e 's/ //g' -e 's/},{/},\n{/g')
      #workers=$(echo "$data" | jq -r '.workers[] | [.workerGroup, .workerId, .latestTask?.taskId] | @tsv')

      states="${states}"$(\
      {
      while IFS= read -r line; do  #dc hostname taskId ; do
        dc=$(echo "$line" | grep -o 'workerGroup":"[^"]\+' | cut -d\" -f3)
        hostname=$(echo "$line" | grep -o 'workerId":"[^"]\+' | cut -d\" -f3)
        taskId=$(echo "$line" | grep -o 'taskId":"[^"]\+' | cut -d\" -f3)
        wget -o /dev/null -q -O - ${queue}/task/${taskId}/status \
            | grep '"state":' | tail -n +2 | cut -d\" -f4 &
            #| jq -r '.status.runs | .[] | [.state] | @tsv' &
            #| jq -r '.status.runs | .[] | [.state, .started, .resolved] | @tsv' &
      done <<< "$workers"
      wait
      } | sort)

      if echo ${data} | grep "continuation" >/dev/null ; then
        continuation=$(echo $data | grep -o 'continuationToken": "[^\"]*"' | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1/')
        sleep 1
      else
        break;
      fi
    done

    running=$(echo "$states" | sort | grep running | wc -l)
    idle=$(( n - running - quarantined ))
    workers=${n}
    #printf "\n\nstates=${states}\nBEFORE\n"
    #states=$(echo "$states" | grep -v '^$' | sort | uniq -c | awk '{print "\""$2"\":"$1","}' | tr -d '\n')
    #printf "\n\nstates=${states}\n\n"
    # add to counts, queue
    tasks=$(curl -s -o - "${queue}/pending/${provisioner}/${type}")
    pending=$(echo "$tasks" | grep pendingTasks | cut -d\: -f2 | sed -e 's/ //g')
    now=$(date -u +%s)000000000
    # 1658805905000000000
    # 2000000000
    #echo "exec,provisionerId=${provisioner// /},workerType=${type// /} running=${running// /},idle=${idle// /},pendingTasks=${pending// /},quarantined=${quarantined// /},workers=${workers// /} ${now}"
    echo "exec,provisionerId=${provisioner// /},workerType=${type// /} idle=${idle// /},pendingTasks=${pending// /},quarantined=${quarantined// /},running=${running// /},workers=${workers// /} ${now}"
  done

  #echo ']'

done

#$show_workers && echo '],'
#echo '"queues":['
#echo '['
#echo "$queues"
#echo "$queues" > $(dirname ${BASH_SOURCE[0]})/queue2_${prov_filter// /_/}.log 2>/dev/null

#echo ']'
#echo '}'
