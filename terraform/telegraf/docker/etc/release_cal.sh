#!/bin/bash

ics=$(curl -L -s -o - "https://www.google.com/calendar/ical/mozilla.com_2d37383433353432352d3939%40resource.calendar.google.com/public/basic.ics" | tee ics)

# Code from StackOverflow user Charles Duffy:
# https://stackoverflow.com/questions/37334681/parsing-ics-file-with-bash

local_date() {
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
  
  version="\"$(echo "${content[SUMMARY]}" | grep -o '[0-9\.]\+ Release' | cut -d' ' -f1)\""
  rel_type=""
  case "${content[SUMMARY]}" in
    Firefox\ ESR*)
      rel_type="ESR"
      ;;
    Firefox*)
      rel_type="Release"
      ;;
    MERGE*)
      rel_type="Merge"
      ;;
  esac
  # time must be a nanosecond precision unix timestamp like 1465839830100400200
  #                                                         1543796160
  # firefox_release,type=Merge,version=\"\" title=\"MERGE: B40\\, A41\\, N42\" 1543796160000000000
  summary=$(echo ${content[SUMMARY]} | cut -d' ' -f1)
  printf 'firefox_release,type="%s",version=%s title="%s" %s000000000\n' "$rel_type" "$version" "$summary" "$(local_date DTSTART +%s)" 
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

