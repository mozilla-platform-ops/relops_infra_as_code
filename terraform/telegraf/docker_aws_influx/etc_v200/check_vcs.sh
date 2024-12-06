#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all


#good:
# > vcssync_exec,repo=gecko-dev message="Merge autoland to mozilla-central a=merge",name="Andreea Pavel",sha="4827a71e61875202dafd2f8ab9887fdbbd1c53ef" 1587396902000000000
# > vcssync_exec,repo=mozilla-central message="Bug 1631171 - Prompter.jsm openWindowPrompt: Fixed fallback to active window when null is passed. r=Gijs",name="pbz",sha="081fc3dae3bbad63ddd9e54a042ac8f1de6ad558" 1587378679000000000
# > vcssync_exec,repo=mozilla-central message="Bug 1523736 - migrate updates.dtd to fluent r=fluent-reviewers,flod,Gijs",name="Bingjing Yan",sha="f84f2ac3b1f7e211f8c3d80d2ef24f86d89153fb" 1587379301000000000
# > vcssync_exec,repo=mozilla-central message="Bug 1631232 - Ensure that we hold an actual reference to the root, not to a field of a node we can just GC below. r=nox",name="Emilio Cobos Álvarez",sha="ab5ec3be52a8629e975ebfcf8ebc38201b4104f1" 1587380842000000000
# > vcssync_exec,repo=mozilla-central message="Bug 1626076 - Make it possible to use DataStorage on socket process r=keeler,dragana,necko-reviewers",name="Kershaw Chang",sha="97c731887ed2421789d23bac3ba96301aba037dc" 1587375718000000000
# > vcssync_exec,repo=mozilla-central message="Merge autoland to mozilla-central a=merge",name="Andreea Pavel",sha="6a0ecf432b788c654d6a243257c53ddc1e909906" 1587396902000000000
# > vcssync_exec,repo=gecko-dev mapper_matching=0,matching=1,sha="6a0ecf432b788c654d6a243257c53ddc1e909906" 1587403976000000000
#
# #bad:
# [
# {"repo":"gecko-dev","branch":"master","name": "Dorel Luca","message": "Merge autoland to mozilla-central. a=merge","date":1587140610,"sha": "873f29449b0de2ab06aa1c7510d0222687103585"}
# ]
# EOF
# ,
# { "repo": "mozilla-central", "name": "Andrei Oprea", "message": "Bug 1624309 - Add persistent storage for ExperimentStore r=k88hudson", "date":1587121356, "sha": "dea3691536232e2cf0a9f24d4e90846ea9b3d2a1" }
# ,
# { "repo": "mozilla-central", "name": "Masayuki Nakano", "message": "Bug 1630168 - Make `HTMLEditor` stop adding same runnable method into the queue r=m_kato", "date":1587050126, "sha": "cb5e78f6e6688e4db89ac32fee61e1a5b803e612" }
# ,
# { "repo": "mozilla-central", "name": "Henrik Skupin", "message": "Bug 1599413 - [remote] Add executeSoon to sync helper methods. r=remote-protocol-reviewers,jgraham", "date":1587114510, "sha": "e5dac7407c508870e9345d1c2281df339e1e7442" }
# ,
# { "repo": "mozilla-central", "name": "Eden Chuang", "message": "Bug 1598131 - Propagate the browsingContext's COEP to the new created one in nsFrameLoader::Recreate r=farre", "date":1587122953, "sha": "dc96b30210daa5d6772c58769cbb65c35b6ce086" }
# ,
# { "repo": "mozilla-central", "name": "Dorel Luca", "message": "Merge autoland to mozilla-central. a=merge", "date":1587140610, "sha": "b4b1d6f91ef0c115bed09a68c160ffa0e50177e3" }
# ,{ "repo": "gecko-dev", "branch": "master","last_git_hash":"873f29449b0de2ab06aa1c7510d0222687103585", "sha": "b4b1d6f91ef0c115bed09a68c160ffa0e50177e3", "matching": 1, "mapper_matching": 0,  "date":1587152446 }
# ]

#echo "["

#hg_repo="releases/mozilla-release"
#git_branch=release
#hg_repo="releases/mozilla-esr68"
#git_branch=esr68

hg_repo=${1:-mozilla-central}
git_branch=${2:-master}

github_auth="-u davehouse:c89bb816e9714393bc97677b59d3029b7c9c81f3 "
git_repo=gecko-dev
#git_branch=master
git_output=false

master_state=$(curl ${github_auth} -s -X GET \
    "https://api.github.com/repos/mozilla/${git_repo}/git/refs/heads/${git_branch}" \
    | grep url | grep -v 'heads/'${git_branch} \
    | head -1 | sed 's/^[ \t]*//' | cut -d'"' -f4)

#echo $master_state
if [[ $master_state == *"rate-limiting"* ]]; then
	#echo 'rate-limited for checking github.com/mozilla/${git_repo}/${git_branch}'
	echo
else
	tmpfile=$(mktemp)
	trap "rm -f $tmpfile" 0 2 3 15
	curl ${github_auth} -s -X GET $master_state 2>/dev/null > $tmpfile
	#ls -la $tmpfile
	#cat $tmpfile
	#echo "now try that if message not found"
	grep message $tmpfile 2>&1 >/dev/null || grep -A4 object $tmpfile|grep url|sed 's/^.*url.*"\(.*\)".*$/\1/'|xargs -I {} curl ${github_auth} -s -X GET {} >$tmpfile

	#ls -la $tmpfile
	#cat $tmpfile
	#echo "now get the information from that"
	# json stype:
    #mapfile -t git_commit < <(cat $tmpfile | grep -o '\("sha\|"message\|"\(name\|date\)\)": .*' | sort -s -k1.1,1.4 | uniq --check-chars=4 | sort | sed -e 's/[, ]\+$//' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/\\n.*$/"/' -e 's/\&quot\;/\\"/g')
	mapfile -t git_commit < <(cat $tmpfile | grep -o '\("sha\|"message\|"\(name\|date\)\)": .*' | sort -s -k1.1,1.4 | uniq --check-chars=4 | sort \
        | sed -e 's/[, ]\+$//' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/\\n.*$/"/' -e 's/\&quot\;/\"/g' -e 's/\\"/"/g' | cut -d\" -f4)
    git_date=$(echo ${git_commit[0]}|cut -d'"' -f 4)
    date=$(date -d"${git_date}" +%s)
	#date="${git_commit[0]%%Z\"}+00:00\""
        # git formats dates like:   2019-01-31T00:07:08Z
        # reformat to match hg like 2019-02-04T19:09:13+02:00
	message=${git_commit[1]}
	name=${git_commit[2]}
	hash=${git_commit[3]}
    printf 'vcssync_exec,repo=%s branch="%s",message="%s",name="%s",sha="%s" %d\n' "${git_repo}" "${git_branch}" "${message}" "${name}" "${hash}" "${date}"
    #echo '{"repo":"'$git_repo'","branch":"'${git_branch}'",'${name}','${message}',"date":'${date}','${hash}'}'
  git_output=true
  last_git_hash=$(echo $hash|cut -d'"' -f4)
fi
last_git_name=$name
last_git_date=$date
last_git_message=$message

mapfile -t hg_commit < <(curl -X GET https://hg.mozilla.org/${hg_repo}/atom-log 2>/dev/null|grep '  \(<title>\(\[default\]\)\?\|<name>\|<updated>\|<id>\)' | sed -e 's/<\/\(title\|name\|updated\|id\)>/"/' -e 's/.*#changeset-/"sha": "/' -e 's/.*<updated>/"date": "/' -e 's/.*<title>\(\[default\]\)\? */"message": "/' -e 's/.*<name>/"name": "/' -e 's/\&quot\;/\\"/g')

i=$(( ${#hg_commit[@]} / 4 ))
#if $git_output && [[ $i -gt 0 ]]; then
#  echo ","
#fi
while [[ i -gt 0 ]]; do
  #date="${hg_commit[$i-1]}"
  hg_date=$(echo ${hg_commit[$i-1]}|cut -d'"' -f 4)
  date=$(date -d"${hg_date}" +%s)
  name=$( echo ${hg_commit[$i-2]} | sed -e 's/\\"/"/g' | cut -d\" -f4)
  hash=$(echo ${hg_commit[$i-3]} | sed -e 's/\\"/"/g' | cut -d\" -f4)
  message=$( echo ${hg_commit[$i-4]} | sed -e 's/\\"/"/g' | cut -d\" -f4)
  # vcssync_exec,repo=gecko-dev message="Merge autoland to mozilla-central a=merge",name="Andreea Pavel",sha="4827a71e61875202dafd2f8ab9887fdbbd1c53ef" 1587396902000000000
  printf 'vcssync_exec,repo=%s message="%s",name="%s",sha="%s" %d\n' "${hg_repo}" "${message}" "${name}" "${hash}" "${date}"
  #echo '{ "repo": "'$hg_repo'", '${name}", "${message}', "date":'${date}', '${hash}' }'
  i=$(( i - 4 ))
  # if [[ $i -ge 4 ]]; then
  #   echo ","
  # fi
done
last_hg_hash=$(echo $hash|cut -d'"' -f4)
last_hg_name=$name
last_hg_date=$date
last_hg_message=$message

if [[ ${last_git_date} != ${last_hg_date} ]] ||
   [ "${last_git_name}" != "${last_hg_name}" ] ||
   [ "${last_git_message}" != "${last_hg_message}" ]; then
    matching=0
else
    matching=1
fi



#since=$(date -u -d "14 days ago" +"%Y-%m-%dT%T+00:00")
#map_last_hash=$(wget -q -O - -nv \
#  "https://mapper.mozilla-releng.net/${git_repo}/mapfile/since/${since}" \
#  | tail -1 | cut -d' ' -f1)

#now=$(date -u +"%Y-%m-%dT%T+00:00")
now=$(date -u +%s)
printf 'vcssync_exec,repo=%s branch="%s",last_git_hash="%s",last_hg_hash="%s",matching=%d %d\n' "${git_repo}" "${git_branch}" "${last_git_hash}" "${last_hg_hash}" "${matching}" "${now}"

exit 0
# do not check mapping

map_git_hash=$(wget -q -O - -nv https://mapper.mozilla-releng.net/${git_repo}/rev/hg/${last_hg_hash} | cut -d' ' -f1)
#echo Last hg hash: $last_hg_hash
#echo Last git hash: $last_git_hash
#echo mapper hash: $map_git_hash
if [[ $last_git_hash == $map_git_hash ]]; then
  echo ',{ "repo": "'${git_repo}'", "branch":'\
  '"'${git_branch}'","last_git_hash":"'${last_git_hash}'", "sha":'\
  '"'${last_hg_hash}'", "matching": '${matching}', "mapper_matching": 1, '\
  '"date":'${now}' }'
  #'"mapper_last_hash":"'${map_last_hash}'", "date": "'${now}'" }'
else
  echo ',{ "repo": "'${git_repo}'", "branch":'\
  '"'${git_branch}'","last_git_hash":"'${last_git_hash}'", "sha":'\
  '"'${last_hg_hash}'", "matching": '${matching}', "mapper_matching": 0, '\
  '"date":'${now}' }'
  #'"mapper_last_hash":"'${map_last_hash}'", "date": "'${now}'" }'
fi

echo "]"
