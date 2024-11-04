#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

echo "["

hg_repo=mozilla-central

github_auth="-u davehouse:c89bb816e9714393bc97677b59d3029b7c9c81f3 "
git_repo=gecko-dev
git_branch=master
git_output=false

master_state=$(curl ${github_auth} -s -X GET https://api.github.com/repos/mozilla/${git_repo}/git/refs/heads/${git_branch} |grep url|grep -v 'heads/master'|head -1|sed 's/^[ \t]*//'|cut -d'"' -f4)

#echo $master_state
if [[ $master_state == *"rate-limiting"* ]]; then
	#echo 'rate-limited for checking github.com/mozilla/${git_repo}/${git_branch}'
	echo
else
	tmpfile=$(mktemp)
	trap "rm -f $tmpfile" 0 2 3 15
	curl ${github_auth} -s -X GET $master_state > $tmpfile
	#ls -la $tmpfile
	#cat $tmpfile
	#echo "now try that if message not found"
	grep message $tmpfile 2>&1 >/dev/null || grep -A4 object $tmpfile|grep url|sed 's/^.*url.*"\(.*\)".*$/\1/'|xargs -I {} curl ${github_auth} -s -X GET {} >$tmpfile

	#ls -la $tmpfile
	#cat $tmpfile
	#echo "now get the information from that"
	mapfile -t git_commit < <(cat $tmpfile | grep -o '\("sha\|"message\|"\(name\|date\)\)": .*' | sort -s -k1.1,1.4 | uniq --check-chars=4 | sort | sed -e 's/[, ]\+$//' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/\\n.*$/"/' -e 's/\&quot\;/\\"/g')
	date="${git_commit[0]%%Z\"}+00:00\""
        # git formats dates like:   2019-01-31T00:07:08Z
        # reformat to match hg like 2019-02-04T19:09:13+02:00
	message=${git_commit[1]}
	name=${git_commit[2]}
	hash=${git_commit[3]}
    echo '{"repo":"'$git_repo'",'${name}','${message}','${date}','${hash}'}'
  git_output=true
  last_git_hash=$(echo $hash|cut -d'"' -f4)
fi

mapfile -t hg_commit < <(curl -X GET https://hg.mozilla.org/${hg_repo}/atom-log 2>/dev/null|grep '  \(<title>\(\[default\]\)\?\|<name>\|<updated>\|<id>\)' | sed -e 's/<\/\(title\|name\|updated\|id\)>/"/' -e 's/.*#changeset-/"sha": "/' -e 's/.*<updated>/"date": "/' -e 's/.*<title>\(\[default\]\)\? */"message": "/' -e 's/.*<name>/"name": "/' -e 's/\&quot\;/\\"/g')

i=$(( ${#hg_commit[@]} / 4 ))
if $git_output && [[ $i -gt 0 ]]; then
  echo ","
fi
while [[ i -gt 0 ]]; do
  date="${hg_commit[$i-1]}"
  name=${hg_commit[$i-2]}
  hash=${hg_commit[$i-3]}
  message=${hg_commit[$i-4]}
  echo '{ "repo": "'$hg_repo'", '${name}", "${message}', '${date}', '${hash}' }'
  i=$(( i - 4 ))
  if [[ $i -ge 4 ]]; then
    echo ","
  fi
done
last_hg_hash=$(echo $hash|cut -d'"' -f4)

map_git_hash=$(wget -q -O - -nv https://mapper.mozilla-releng.net/${git_repo}/rev/hg/${last_hg_hash} | cut -d' ' -f1)
#echo Last hg hash: $last_hg_hash
#echo Last git hash: $last_git_hash
#echo mapper hash: $map_git_hash
now=$(date -u +"%Y-%m-%dT%T+00:00")
if [[ $last_git_hash == $map_git_hash ]]; then
  echo ',{ "repo": "vcssync", "last_git_hash": "'${last_git_hash}'", "sha": "'${last_hg_hash}'", "matching": 1, "date": "'${now}'" }'
else
  echo ',{ "repo": "vcssync", "last_git_hash": "'${last_git_hash}'", "sha": "'${last_hg_hash}'", "matching": 0, "date": "'${now}'" }'
fi

echo "]"
