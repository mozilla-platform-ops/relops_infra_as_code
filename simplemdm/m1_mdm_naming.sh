#!/bin/bash

group=${1:-gecko_t_osx_1100_m1}

hn_tail=".test.releng.mslv.mozilla.com"
for I in {002..050}; do
    hn=macmini-m1-$((10#$I))
    target_name=V-MM$I
    serial=$(ssh -o LogLevel=ERROR -o StrictHostKeyChecking=no -o ConnectTimeout=40 -o UserKnownHostsFile=/dev/null ${hn}${hn_tail} 'ioreg -l | grep IOPlatformSerialNumber | cut -d\" -f4')
    if [[ ${#serial} -gt 0 ]]; then
        ./nameit.sh $group "${target_name}" "${serial}" $hn
    else
        echo "$hn serial not found."
    fi
done
