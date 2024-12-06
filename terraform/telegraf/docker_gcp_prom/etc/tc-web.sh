#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

batch_limit=1000

# example from client
# curl 'https://taskcluster-web-server.herokuapp.com/graphql' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://taskcluster-web.netlify.com/provisioners/releng-hardware/worker-types/gecko-t-osx-1010' -H 'content-type: application/json' -H 'Origin: https://taskcluster-web.netlify.com' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data '{"operationName":"ViewWorkers","variables":{"provisionerId":"releng-hardware","workerType":"gecko-t-osx-1010","workersConnection":{"limit":15}},"query":"query ViewWorkers($provisionerId: String!, $workerType: String!, $workersConnection: PageConnection, $quarantined: Boolean) {\n  workers(provisionerId: $provisionerId, workerType: $workerType, connection: $workersConnection, isQuarantined: $quarantined) {\n    pageInfo {\n      hasNextPage\n      hasPreviousPage\n      cursor\n      previousCursor\n      nextCursor\n      __typename\n    }\n    edges {\n      node {\n        latestTask {\n          run {\n            workerGroup\n            workerId\n            taskId\n            runId\n            started\n            resolved\n            state\n            __typename\n          }\n          __typename\n        }\n        firstClaim\n        quarantineUntil\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n  workerType(provisionerId: $provisionerId, workerType: $workerType) {\n    actions {\n      name\n      description\n      title\n      url\n      __typename\n    }\n    __typename\n  }\n  provisioners {\n    edges {\n      node {\n        provisionerId\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n"}'

# do not show the workers. only by provisioner
show_workers=false

prov_filter=("$@")

#queue="https://queue.taskcluster.net/v1"
#url='https://taskcluster-web-server.herokuapp.com/graphql'

# new urls after TCW Nov 9th 2019:
queue='https://firefox-ci-tc.services.mozilla.com/api/queue/v1'
url='https://firefox-ci-tc.services.mozilla.com/graphql'

provisioners=$(curl -s -o - "${queue}/provisioners" \
  | grep '"provisionerId' \
  | awk '{print $2}' | grep -Eo '[^":, \[]*' \
)

queues=""
debug="***\n"

qcomma=""
comma=""
#echo '{'
$show_workers && echo '"workers":['
#for provisioner in $provisioners; do
for provisioner in "${prov_filter[@]}"; do
  #found=false
  #for p in "${prov_filter[@]}"; do
  #  # echo $provisioner == "$p"
  #  [[ $provisioner == "$p" ]] || continue
  #  found=true
  #  break
  #done
  #if ! $found; then
  #  continue
  #fi

  # echo ${comma}'"'${provisioner}'":['
  workerTypes=$(curl -s -o - "${queue}/provisioners/${provisioner}/worker-types" \
    | grep workerType \
    | awk '{print $2}' | grep -Eo '[^":, \[]+' \
  )

  for workerType in $workerTypes; do
    # if [ $workerType != "gecko-t-osx-1010" ]; then
    #   continue
    # fi

    data=""
    continuation='"limit":'"${batch_limit}"
    n=0
    quarantined=0
    total=0
    running=0
    idle=0
    while true ;do
      #  -H "Referer: https://taskcluster-web.netlify.com/provisioners/${provisioner}/worker-types/${workerType}" \
      #  -H 'Origin: https://taskcluster-web.netlify.com' \
      data=$(curl -s -o - "${url}" \
        -H 'content-type: application/json' \
        -H 'DNT: 1' \
        --data '{"operationName":"ViewWorkers","variables":{"provisionerId":"'"${provisioner}"'","workerType":"'"${workerType}"'","workersConnection":{'$continuation'}},"query":"query ViewWorkers($provisionerId: String!, $workerType: String!, $workersConnection: PageConnection, $quarantined: Boolean) {\n  workers(provisionerId: $provisionerId, workerType: $workerType, connection: $workersConnection, isQuarantined: $quarantined) {\n    pageInfo {\n      hasNextPage\n      hasPreviousPage\n      cursor\n      previousCursor\n      nextCursor\n      __typename\n    }\n    edges {\n      node {\n        latestTask {\n          run {\n            workerGroup\n            workerId\n            taskId\n            runId\n            started\n            resolved\n            state\n            __typename\n          }\n          __typename\n        }\n        workerGroup\n  workerId\n        quarantineUntil\n        }\n      }\n    }\n  }\n"}'
      )
#echo $data > tmpout

      cursor=$(echo $data | jq '.data.workers.pageInfo.nextCursor' 2>/dev/null)
      previous_cursor=$(echo $data | jq '.data.workers.pageInfo.cursor' 2>/dev/null)
      hasNextPage=$(echo $data | jq '.data.workers.pageInfo.hasNextPage' 2>/dev/null)
      continuation='"limit":'"${batch_limit}"',"cursor":'"${cursor}"',"previousCursor":'"${previous_cursor}"

      #echo $comma
      data=$(echo "$data" | jq '.data.workers.edges[].node | select(. | has("latestTask")) | {taskId: "", state: "IDLE"} + .latestTask?.run + {provisionerId: "'${provisioner}'", workerGroup: .workerGroup, workerId: .workerId, quarantineUntil: .quarantineUntil}' \
        | grep -v 'runId\|typename\|started\|resolved' \
        | tr -d '\n' | sed -e 's/[ \t]\+//g' -e 's/,\?}{/},{/g' -e 's/,}$/}/' -e 's/},{/},\n{/g'
      )

      ntotal=$(echo "$data" | grep state | wc -l)
      nrunning=$(echo "$data" | grep state | grep RUNNING | wc -l)
      qcount=$(echo "$data" | grep quarantineUntil | grep -v null | wc -l)
      nidle=$(echo "$data" | grep state | grep -v RUNNING | wc -l)
      nidle=$(( nidle - qcount ))  # do not count quarantined as idle
      total=$(( total + ntotal ))
      running=$(( running + nrunning ))
      idle=$(( idle + nidle ))
      quarantined=$(( quarantined + qcount ))

      comma=','

      if [[ "${hasNextPage}" != "true" ]]; then
        break
      else
        continue
      fi
exit 0
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
      if echo ${data} | grep "continuation" >/dev/null ; then
        continuation=$(echo $data | grep -o 'continuationToken": "[^\"]*"' | sed -e 's/.*continuationToken": "\([^"]*\)".*/\&continuationToken=\1/')
        sleep 2
      else
        break;
      fi
    done
    if [[ $n -gt 0 ]]; then
      comma=","
    fi

    # add to counts, queue
    tasks=$(curl -s -o - "${queue}/pending/${provisioner}/${workerType}")
    tasks1=$(echo "$tasks" | sed -e 's/pendingTasks/workers": '${total}',\n  "pendingTasks/')
    tasks2=$(echo "$tasks1" | sed -e 's/pendingTasks/runningWorkers": '${running}',\n  "pendingTasks/')
    tasks3=$(echo "$tasks2" | sed -e 's/pendingTasks/idleWorkers": '${idle}',\n  "pendingTasks/')
    tasks4=$(echo "$tasks3" | sed -e 's/pendingTasks/quarantinedWorkers": '${quarantined}',\n  "pendingTasks/')
    queues="${queues}${qcomma}${tasks4}"
    qcomma=","
    #continue

  done

  #echo ']'

done

$show_workers && echo '],'
#echo '"queues":['
(
echo '['
echo "$queues"
echo ']'
) | tee $(dirname ${BASH_SOURCE[0]})/tc-web.log
#echo '}'

