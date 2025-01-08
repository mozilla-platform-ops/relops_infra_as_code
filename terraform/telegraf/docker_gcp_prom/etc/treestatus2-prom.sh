#!/bin/bash

# Disable shellcheck warnings
# shellcheck disable=all

set -e

# source common.sh
source "$(dirname "$0")/common.sh"

# Set the filename for the downloaded .ics file
filename=${1:-firefox.ics}
# URL of the calendar to fetch
url='https://www.google.com/calendar/ical/mozilla.com_2d37383433353432352d3939%40resource.calendar.google.com/public/basic.ics'

# Download the .ics file
ics=$(curl -L -s -o - "${url}" | tee "${filename}")

# Metric prefix for Prometheus metrics
metric_prefix=${METRIC_PREFIX:-"release_calendar_event"}

# Function to convert a date to a UNIX timestamp
function local_date() {
  local tz=${tzid[$1]}
  local dt=${content[$1]}
  if [[ $dt = *Z ]]; then
    tz=UTC
    dt=${dt%Z}
  fi

  if [[ $dt = *T* ]]; then
    dt="${dt:0:4}-${dt:4:2}-${dt:6:2}T${dt:9:2}:${dt:11:2}"
  else
    dt="${dt:0:4}-${dt:4:2}-${dt:6:2}"
  fi

  # Detect the operating system
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Use GNU date
    date --date="TZ=\"$tz\" $dt" +%s
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Use BSD/macOS date
    TZ="$tz" date -j -f "%Y-%m-%dT%H:%M" "$dt" +%s 2>/dev/null || \
    TZ="$tz" date -j -f "%Y-%m-%d" "$dt" +%s
  else
    echo "Unsupported OS: $OSTYPE" >&2
    exit 1
  fi
}

# Handle each VEVENT and output in Prometheus format
handle_event() {
  local rel_type=""
  local summary=""
  local version=""

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
      version=$(echo "${content[SUMMARY]}" | grep -Eo '[0-9]+' | head -1)
      ;;
    *)
      rel_type="Unknown"
      summary=${content[SUMMARY]//\\/}
      version="0"
      ;;
  esac

  # Output metrics in Prometheus exposition format
  start_time=$(local_date DTSTART)
  echo "${metric_prefix}{type=\"$rel_type\",version=\"$version\",summary=\"$summary\"} $start_time"
}

# Parse the .ics file
declare -A content=() # Associative array for event content
declare -A tzid=()    # Associative array for timezone info

# Print HELP and TYPE comments once per metric
echo "# HELP ${metric_prefix} Release calendar event."
echo "# TYPE ${metric_prefix} gauge"

while IFS=: read -r key value; do
  value=${value%$'\r'} # Remove DOS newlines
  if [[ $key = END && $value = VEVENT ]]; then
    handle_event
    content=()
    tzid=()
  else
    if [[ $key = *";TZID="* ]]; then
      tzid[${key%%";"*}]=${key##*";TZID="}
    fi
    content[${key%%";"*}]=$value
  fi
done <<<"$ics"
