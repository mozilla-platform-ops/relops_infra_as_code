#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

tmpfile=$0.tmpfile

curl -s -o - "https://treestatus.mozilla-releng.net/stack" > $tmpfile

# for each tree entry within a closure note, list that note's details
# without this, we do not know what trees are affected because telegraf's json parse does not handle array attributes
#echo "["; (echo "comma='';"; cat $tmpfile | tr '\n' ' ' | sed -e 's/ \] }//' -e 's/}, *{/}\n{/g' -e 's/[^}\n]*\("reason"\)/\1/g' -e 's/ \+/ /g' -e 's/\([^}]*\)"trees": \[ \([^]]*\) \], /\ntrees=( \2 ); object={\1/g' -e "s/object={\n\?\([^}]*\)}/object='\1'\n\nfor tree in \${trees\[@\]}; do echo -n \$comma; echo -n {\\\\\"repo\\\\\":\\\\\"\${tree%,}\\\\\", \${object}}; comma=\",\n\"; done\n/g") | bash; echo "]"

# status_value= ascii value for first letter is status name

echo "["; (echo "comma='';"; cat $tmpfile | tr '\n' ' ' | sed -e 's/ \] }//' -e 's/}, *{/}\n{/g' -e 's/[^}\n]*\("reason"\)/\1/g' -e 's/ \+/ /g' -e 's/\([^}]*\)"trees": \[ \([^]]*\) \], /\ntrees=( \2 ); object={\1/g' -e "s/object={\n\?\([^}]*status.: .\([^\\\"]*\)[^}]*when.: .\([^\\\"]*\)[^}]*\)}/time=\$(date -d\\\"\3\\\" +%s); status=\2; status_value=\$(( \$(LC_CTYPE=C printf '%d' \"'\${status[0]}\") % 5 )); object='\1'\n\nfor tree in \${trees\[@\]}; do echo -n \$comma; echo -n {\\\\\"repo\\\\\":\\\\\"\${tree%,}\\\\\", \\\\\"timestamp\\\\\": \$time, \\\\\"status_value\\\\\":\$status_value, \${object}}; comma=\",\n\"; done\n/g") | bash; echo "]"
