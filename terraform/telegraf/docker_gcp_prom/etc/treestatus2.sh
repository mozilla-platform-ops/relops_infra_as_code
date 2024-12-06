#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

PATH="$PATH:$(dirname ${BASH_SOURCE[0]})"

parallel=1


tmpfile=$0.tmpfile

# status_value= ascii value for first letter is status name
#echo "["; (echo "comma='';"; cat $tmpfile | tr '\n' ' ' | sed -e 's/ \] }//' -e 's/}, *{/}\n{/g' -e 's/[^}\n]*\("reason"\)/\1/g' -e 's/ \+/ /g' -e 's/\([^}]*\)"trees": \[ \([^]]*\) \], /\ntrees=( \2 ); object={\1/g' -e "s/object={\n\?\([^}]*status.: .\([^\\\"]*\)[^}]*when.: .\([^\\\"]*\)[^}]*\)}/time=\$(date -d\\\"\3\\\" +%s); status=\2; status_value=\$(( \$(LC_CTYPE=C printf '%d' \"'\${status[0]}\") % 5 )); object='\1'\n\nfor tree in \${trees\[@\]}; do echo -n \$comma; echo -n {\\\\\"repo\\\\\":\\\\\"\${tree%,}\\\\\", \\\\\"timestamp\\\\\": \$time, \\\\\"status_value\\\\\":\$status_value, \${object}}; comma=\",\n\"; done\n/g") | bash; echo "]"

trees=$(curl -s -o - "https://treestatus.mozilla-releng.net/trees" \
  | jq -r '.result[] | [.tree] | @tsv' \
)

function get_state()
{
  # each tree gets a separate array (telegraf json cannot parse without being combined)
  #curl -s -o - "https://treestatus.mozilla-releng.net/trees/${1}/logs?all=0" \
  #  | jq -r -c '.result[]|del(.tags)' \
  #  | tr '\n' ','

  #date format: 2019-04-03T16:20:52.502125+00:00

  # 2019-11-21T16:35:49Z D! [inputs.exec] Error in plugin: metric parse error: expected field at 2:163: "treestatus,tree=ash,status=closed status=\"closed\",status_value=4,who=\"mozilla-auth0/ad|Mozilla-LDAP|shindli/releng-treestatus-production-ABxoAP\",reason=\"Jobs don\"t show up on pushes\" 1574089559000000000"


  tree="$1"
  {
  while read -r line ; do
    #echo "[$line]"
    eval "$line"

    false && (
    echo "when=$when"
    echo "tree=$tree"
    echo "status=$status"
    echo "who=$who"
    echo "reason=$reason"
    )
    timestamp=$(date +"%s000000000" -d "${when//\'/}")
    when=""

    status_value=$(( $(LC_CTYPE=C printf '%d' "'${status[0]}") % 5 ))

    printf 'treestatus,tree=%s,status="%s" status="%s",status_value=%d,who="%s",reason="%s" %d\n' \
      "$tree" "${status// /_}" "$status" "$status_value" "$who" "${reason//\"/\'}" $timestamp
      #| tr \' \"

  done <<< "$( \
    curl -s -o - 'https://treestatus.mozilla-releng.net/trees/'${tree}'/logs' \
      | jq -r -c '.result[] | del(.tags) | @sh "reason=\(.reason) tree=\(.tree) who=\(.who) when=\(.when) status=\(.status)"'
  )"
  }
}
export -f get_state

echo "$trees" \
  | xargs -P$parallel -L1 -I{} bash -c 'get_state {}; exit 0'

# example: influx line format
# tc_queue_exec,host=telegraf-getting-started,provisionerId=releng-hardware,workerType=gecko-t-win10-64-ux completed=2,failed=2,idle=4,pendingTasks=5,quarantinedWorkers=0,running=6,workers=10 1553621929000000000
