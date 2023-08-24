#!/bin/bash

if [[ ! -v 'SIMPLE_MDM_API_KEY' ]]; then
    echo "SIMPLE_MDM_API_KEY environment variable must be set"
    exit 1
fi

target_group=${1:-gecko_t_osx_1100_m1}
target=${2}
echo "target_group=${target_group}"
echo "target=${target}"
serial=${3}
echo "serial=${serial}"
target_device_name=${4:-${target}}
echo "target_device_name=${target_device_name}"

function post() {
    act=${1:-account}
    args=${2:-"-X POST"}
    data=""
    echo curl -q "${args}" "https://a.simplemdm.com/api/v1/${act}" >&2
    page=$(curl -q "${args}" "https://a.simplemdm.com/api/v1/${act}" \
        --fail \
        -u "${SIMPLE_MDM_API_KEY}:" )
    echo $? >&2
    page_data=$(echo "$page" | jq -r '.data')
    page_data=${page_data%%\]}
    if [[ -z "${data}" ]]; then
        between=''
    else
        between=','
    fi
    data="${data}${between}${page_data##\[}"

    echo "[${data}]"
}

function callit() {
    act=${1:-account}
    args=${2:-""}
    data=""
    has_more="true"
    more_msg="Collecting pages"
    starting_after=''
    last_starting=''
    while [[ 'true' == "${has_more}" ]]; do
        page=$(curl -q "${args}https://a.simplemdm.com/api/v1/${act}${starting_after}" \
            --fail \
            -u "${SIMPLE_MDM_API_KEY}:" 2>/dev/null)
        page_data=$(echo "$page" | jq -r '.data')
        page_data=${page_data%%\]}
        if [[ -z "${data}" ]]; then
            between=''
        else
            between=','
        fi
        data="${data}${between}${page_data##\[}"
        has_more=$(echo "$page" | jq -r '.has_more')
        last_id=$(echo "$page" | jq -r '.data[-1] | .id' 2>/dev/null)
        starting_after="&starting_after=$last_id"
        if [[ "${last_id}" != '' ]] && [[ "${last_id}" == "${last_starting}" ]]; then
            echo "(retried pages from last_id='${last_id}')" >&2
            break
        fi
        last_starting=$last_id
        if [[ "${act}" != *"?"* ]]; then
            starting_after="?${starting_after#&}"
        fi
        if [[ 'true' == "${has_more}" ]]; then
            printf "%s" "$more_msg" >&2
            more_msg='.'
        fi
    done

    echo "[${data}]"
}

function find_group_id() {
    group=$1
    declare -A groups
    while read -r id name; do
        groups[$name]=$id
    done <  <(callit device_groups \
        | jq -r '.[] | [.id,.attributes.name] | @tsv')

    if [ -v "groups[$group]" ]; then
        echo "${groups[$group]}"
    fi
}

function rename() {
    id=$1
    name=$2
    device_name=${3:-${name}}
    echo "Rename $id as $name ($device_name)"
    post "devices/${id##* }?name=${name}&device_name=${device_name}" "-X PATCH"
}

data=$(callit "devices?search=${serial}&include_awaiting_enrollment=true")
device_id=$(echo "$data" | grep -m1 '"id":' | cut -d: -f2)
device_id=${device_id%%,}
device_id=${device_id##* }
device_name=$(echo "$data" | grep -m1 '"device_name":' | cut -d\" -f4)
name=$(echo "$data" | grep -m1 '"name":' | cut -d\" -f4)
group_id=$(echo "$data" | jq -r '.[]|.relationships.device_group.data.id')
if [[ "${device_name}" != "${target_device_name}" ]] || [[ "${name}" != "${target}" ]]; then
    echo "rename $device_id as $target [device_name=${device_name}, name=${name}]"
    rename "$device_id" "$target" "$target_device_name"
fi

group_name=$(callit "device_groups/${group_id}" | jq -r '.[]|.attributes.name')
if [[ "${group_name}" != "${target_group}" ]]; then
    target_group_id=$(find_group_id "${target_group}")
    echo "wrong group ${group_name}[${group_id}]. Need to set it to ${target_group}[${target_group_id}]."
    #https://a.simplemdm.com/api/v1/device_groups/{DEVICE_GROUP_ID}/devices/{DEVICE_ID}
    post "device_groups/${target_group_id}/devices/${device_id}"
else
    echo "correct group ${group_name}[${group_id}]"
fi
