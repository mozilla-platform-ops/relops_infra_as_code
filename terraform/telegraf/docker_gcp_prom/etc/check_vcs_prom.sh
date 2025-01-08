#!/bin/bash

# Disable shellcheck for this script
# shellcheck disable=all

set -e

# source common.sh
. "$(dirname "$0")/common.sh"

hg_repo=${1:-mozilla-central}
git_branch=${2:-master}

# Authentication for GitHub (if needed)
# disable auth for now, doesn't seem to be required'
# github_auth="-u user_abc:key_123 "
github_auth=" "

git_repo=gecko-dev

master_state=$(curl ${github_auth} -s -X GET \
    "https://api.github.com/repos/mozilla/${git_repo}/git/refs/heads/${git_branch}" \
    | grep url | grep -v "heads/${git_branch}" \
    | head -1 | sed 's/^[ \t]*//' | cut -d'"' -f4)

if [[ $master_state == *"rate-limiting"* ]]; then
    echo "# Rate-limited for checking GitHub API"
    exit 1
fi

tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT
curl ${github_auth} -s -X GET "$master_state" 2>/dev/null > "$tmpfile"

grep message "$tmpfile" >/dev/null || grep -A4 object "$tmpfile" | grep url | sed 's/^.*url.*"\(.*\)".*$/\1/' | xargs -I {} curl ${github_auth} -s -X GET {} > "$tmpfile"

mapfile -t git_commit < <(cat "$tmpfile" | grep -o '\("sha\|"message\|"\(name\|date\)\)": .*' \
    | sort -s -k1.1,1.4 | uniq --check-chars=4 | sort \
    | sed -e 's/[, ]\+$//' -e 's/^[ \t]*//;s/[ \t]*$//' -e 's/\\n.*$/"/' -e 's/\&quot\;/\"/g' -e 's/\\"/"/g' \
    | cut -d\" -f4)

git_date=$(echo "${git_commit[0]}" | cut -d'"' -f 4)
date=$(date -d"${git_date}" +%s%3N)
message=${git_commit[1]}
name=${git_commit[2]}
hash=${git_commit[3]}

# Output in Prometheus format
echo "# HELP ${metric_prefix}vcssync_exec_last_sync_time Timestamp of the last sync operation."
echo "# TYPE ${metric_prefix}vcssync_exec_last_sync_time gauge"
echo "${metric_prefix}vcssync_exec_last_sync_time{repo=\"${git_repo}\",branch=\"${git_branch}\",message=\"${message}\",name=\"${name}\",sha=\"${hash}\"} 1 ${date}"

# Fetch and process Mercurial commits
echo "# HELP ${metric_prefix}vcssync_exec_commit Commit information from Mercurial."
echo "# TYPE ${metric_prefix}vcssync_exec_commit gauge"
mapfile -t hg_commit < <(curl -X GET "https://hg.mozilla.org/${hg_repo}/atom-log" 2>/dev/null \
    | grep '  \(<title>\(\[default\]\)\?\|<name>\|<updated>\|<id>\)' \
    | sed -e 's/<\/\(title\|name\|updated\|id\)>/"/' -e 's/.*#changeset-/"sha": "/' \
    -e 's/.*<updated>/"date": "/' -e 's/.*<title>\(\[default\]\)\? */"message": "/' -e 's/.*<name>/"name": "/' -e 's/\&quot\;/\\"/g')

i=$(( ${#hg_commit[@]} / 4 ))
while [[ i -gt 0 ]]; do
    hg_date=$(echo "${hg_commit[$i-1]}" | cut -d'"' -f 4)
    date=$(date -d"${hg_date}" +%s%3N)
    name=$(echo "${hg_commit[$i-2]}" | sed -e 's/\\"/"/g' | cut -d\" -f4)
    hash=$(echo "${hg_commit[$i-3]}" | sed -e 's/\\"/"/g' | cut -d\" -f4)
    message=$(echo "${hg_commit[$i-4]}" | sed -e 's/\\"/"/g' | cut -d\" -f4)

    echo "${metric_prefix}vcssync_exec_commit{repo=\"${hg_repo}\",message=\"${message}\",name=\"${name}\",sha=\"${hash}\"} 1 ${date}"
    i=$(( i - 4 ))
done

# Matching check
if [[ ${last_git_date} != ${last_hg_date} ]] ||
   [ "${last_git_name}" != "${last_hg_name}" ] ||
   [ "${last_git_message}" != "${last_hg_message}" ]; then
    matching=0
else
    matching=1
fi

now=$(($(date -u +%s%N) / 1000000))
echo "# HELP ${metric_prefix}vcssync_exec_status Status of the VCS sync operation."
echo "# TYPE ${metric_prefix}vcssync_exec_status gauge"
echo "${metric_prefix}vcssync_exec_status{repo=\"${git_repo}\",branch=\"${git_branch}\",matching=\"${matching}\"} 1 ${now}"
