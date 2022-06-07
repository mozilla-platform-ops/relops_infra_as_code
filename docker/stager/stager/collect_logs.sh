#!/usr/bin/env bash
file=${1:-staged.json}
parallel=${2:-8}
search_papertrail=${3:-false}
limit=${4:-1000}

echo $file
ls -la "$file"
echo $parallel
echo $(( $parallel + 0 ))
echo $search_papertrail
if ! $search_papertrail; then
    echo "not search papertrail"
fi
if $search_papertrail; then
    echo "search papertrail"
fi
echo $limit
echo $(( $limit + 0 ))

mkdir logs 2>/dev/null
mkdir logs/claim-expired 2>/dev/null
mkdir logs/failed 2>/dev/null
mkdir logs/completed 2>/dev/null

mkdir copy_logs 2>/dev/null
mkdir copy_logs/claim-expired 2>/dev/null
mkdir copy_logs/failed 2>/dev/null
mkdir copy_logs/completed 2>/dev/null

function get() {
    copied_taskId=$1
    taskId=$2
    local host=""
    local status=$(
        wget -q -O - https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${taskId}/status
    )
    local copied_status=$(
        wget -q -O - https://firefox-ci-tc.services.mozilla.com/api/queue/v1/task/${copied_taskId}/status
    )
    local state=$(echo "$status" | grep -m1 -o 'state": "[^"]*"' | sed -e 's/.*state": "\([^\"]*\)".*/\1/')
    local copied_state=$(echo "$copied_status" | grep -m1 -o 'state": "[^"]*"' | sed -e 's/.*state": "\([^\"]*\)".*/\1/')
    if true; then ##! $search_papertrail || [[ $state != 'completed' ]]; then
        workerId=$(echo "$status" | grep -m1 -o 'workerId": "[^"]*"' | sed -e 's/.*workerId": "\([^\"]*\)".*/\1/')
        local runId=$(echo "$status" | grep -m1 runId | sed -e 's/.*runId": \([0-9]*\).*/\1/')
        echo "workerId:${workerId} ${taskId} ${state} ${copied_taskId} ${copied_state}"

        if [ ! -f "logs/${state}/${taskId}.live_backing.log" ]; then
            curl --silent -L \
                -o "logs/${state}/${taskId}.live_backing.log" \
                "https://firefoxci.taskcluster-artifacts.net/${taskId}/${runId}/public/logs/live_backing.log" \
                &
        fi

        local copied_runId=$(echo "$copied_status" | grep -m1 runId | sed -e 's/.*runId": \([0-9]*\).*/\1/')
        if [ ! -f "copy_logs/${copied_state}/${copied_taskId}.live_backing.log" ]; then
            curl --silent -L \
                -o "copy_logs/${copied_state}/${copied_taskId}.live_backing.log" \
                "https://firefoxci.taskcluster-artifacts.net/${copied_taskId}/${copied_runId}/public/logs/live_backing.log" \
                &
        fi

        if false && $search_papertrail; then
            local start=$(echo "$status" | grep -m1 -o 'started": "[^"]*"' | sed -e 's/.*started": "\([^\"]*\)".*/\1/')
            local end=$(echo "$status" | grep -m1 -o 'resolved": "[^"]*"' | sed -e 's/.*resolved": "\([^\"]*\)".*/\1/')

            search_start=$(gdate -u --date="${start}" --iso-8601=seconds)
            for search_range in {5,15,40}\ minutes; do
                search_end=$(gdate -u --date="${search_start} + ${search_range}" --iso-8601=seconds)
                host=$(\
                    for collect_retry in {1..3}; do
                        papertrail --group "taskcluster workers" \
                            --min-time "${search_start}" --max-time "${search_end}" \
                            program:docker-worker ${workerId} \
                        | grep -m1 "${workerId}" \
                        | sed -Ee 's/.* ([^ ]+) docker-worker:.*/\1/'\
                        && break
                        sleep $(( collect_retry * 10 ))
                    done
                )
                if ! [[ -z "$host" ]]; then
                    echo "$search_range host:${host} workerId:${workerId} taskId:${taskId} state:${state}"
                    break
                fi
                search_start=$search_end
            done

            for collect_retry in {1,3,6}; do
                papertrail --group "taskcluster workers" --system "$host" --min-time "${start}" --max-time "${end}" program:docker-worker \
                    > "logs/${state}/${taskId}.${host}.log" \
                    && break
                echo retry sleep $(( collect_retry * 10 ))
                sleep $(( collect_retry * 10 ))
            done
        fi
    fi
}

i=0
declare -A states
export -f get
jq -r 'to_entries[] | [.key, .value] | @tsv' <${file} \
    | head -"$limit" \
    | gxargs -P $parallel -d '\n' -I{} \
        sh -c 'get {}; exit 0'

false && (
for log in logs/*/*live*; do
    printf "$log %s\n" \
        "$((cat ${log} || zcat --stdout ${log} || gzcat --stdout ${log}) | tail -10 | grep -v PERFHERDER | grep -Eio 'Connection reset by peer|Task timeout|TBPL FAILURE|ERROR.*')"
done
)
