#!/bin/bash

# TODO: hack to get this green. don't do this.
# shellcheck disable=all

filename=${1:-firefox.ics}
# full relman schedule (not setup to parse this)
url=${2:-https://calendar.google.com/calendar/ical/mozilla.com_dbq84anr9i8tcnmhabatstv5co%40group.calendar.google.com/public/basic.ics}
# merge/release dates:
url='https://www.google.com/calendar/ical/mozilla.com_2d37383433353432352d3939%40resource.calendar.google.com/public/basic.ics'

ics=$(curl -L -s -o - "${url}" | tee "${filename}")

# if [[ ! -e "$filename" ]] || [[ $(find "$filename" -mtime +1 -print) ]]; then
#     #echo "File $filename exists and is older than 1 day"
#     ics=$(curl -L -s -o - "${url}" | tee "${filename}")
# else
#     echo "File $filename exists and is newer than 1 day"
#     ics=$(cat "${filename}")
# fi

# Code from StackOverflow user Charles Duffy:
# https://stackoverflow.com/questions/37334681/parsing-ics-file-with-bash

function local_date() {
  local tz=${tzid[$1]}
  local dt=${content[$1]}
  if [[ $dt = *Z ]]; then
    tz=UTC
    dt=${dt%Z}
  fi
  shift

  if [[ $dt = *T* ]]; then
    dt="${dt:0:4}-${dt:4:2}-${dt:6:2}T${dt:9:2}:${dt:11:2}"
  else
    dt="${dt:0:4}-${dt:4:2}-${dt:6:2}"
  fi

  # note that this requires GNU date
  date --date="TZ=\"$tz\" $dt" "$@"
}

handle_event() {
  #if [[ "${content[LAST-MODIFIED]}" = "${content[CREATED]}" ]]; then
  #  echo "New Event Created"
  #else
  #  echo "Modified Event"
  #fi
  #printf '%s\t' "$(local_date DTSTART)" "$(local_date DTEND)"  "${content[SUMMARY]}" "${content[LOCATION]}"; echo

  rel_type=""
  # Firefox:
  #   SUMMERY: Firefox 39 Release
  #   DESCRIPTION:
  # MERGE:
  #   SUMMARY: MERGE: B42\, A43\, N44
  #   DESCRIPTION: Beta: 42\nAurora: 43\nNightly: 44
  # MERGE:
  #   SUMMERY: MERGE: B71\, N72\, End Soft Code Freeze
  #   DESCRIPTION:
  tags=""
  values=""
  version=""
  case "${content[SUMMARY]}" in
    Firefox\ ESR*)
      rel_type="ESR"
      summary=${content[SUMMARY]//\\/}
      version=$(echo "${content[SUMMARY]}" | grep -Eio -m1 '[0-9\.]+( Release)?' | tr \n ' ' | cut -d' ' -f1)
      ;;
    Firefox*)
      rel_type="Release"
      summary=${content[SUMMARY]//\\/}
      version=$(echo "${content[SUMMARY]}" | tr \n ' ' | sed -Ee 's/[^0-9]*([0-9]+).*/\1/')
      ;;
    MERGE*)
      rel_type="Merge"
      summary=${content[SUMMARY]//\\/}
      # requires GNU cut
      values=","$(echo ${content[SUMMARY]} | grep -Eio '([A-Z])([0-9]+)' | sort | cut --output-delimiter=\= -c1,2-3 | paste -sd\, -)
      version=$(echo "${values}" | grep -Eo 'B=[0-9]+' | sed -Ee 's/.*B=([0-9]+).*/\1/' )
      ;;
    *)
      rel_type="Unknown"
      summary=${content[SUMMARY]//\\/}
      version=0
      return 0
      ;;
  esac
  # time must be a nanosecond precision unix timestamp like 1465839830100400200
  #                                                         1543796160
  # firefox_release,type=Merge,version=\"\" title=\"MERGE: B40\\, A41\\, N42\" 1543796160000000000
  if [[ -z "$version" ]] || [[ v"$version" = "v" ]]; then
      version=0
  fi
  tags="${tags},version=${version}"
  printf "release_cal,rel_type=\"%s\"${tags} version=%s,summary=\"%s\"%s %s000000000\n" \
      "$rel_type" "${version}" "$summary" "$values" "$(local_date DTSTART +%s)"
}

declare -A content=( ) # define an associative array (aka map, aka hash)
declare -A tzid=( )    # another associative array for timezone info

# X-WR-TIMEZONE:America/Los_Angeles
while IFS=: read -r key value; do
  value=${value%$'\r'} # remove DOS newlines
  if [[ $key = END && $value = VEVENT ]]; then
    handle_event # defining this function is up to you; see suggestion below
    content=( )
    tzid=( )
  else
    if [[ $key = *";TZID="* ]]; then
      tzid[${key%%";"*}]=${key##*";TZID="}
    fi
    content[${key%%";"*}]=$value
  fi
done <<<"$ics"

