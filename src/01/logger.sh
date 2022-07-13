#!/bin/bash

function record() {
  local filename
  filename="$1"

  local logfile
  logfile="$2"

  local fileinfo
  fileinfo="$(ls -l --time-style=full-iso --block-size=K "$filename")"

  local size
  size="$(awk '{print $5}' <<<"$fileinfo")"

  local date
  date="$(awk '{print $6, _$7}' <<<"$fileinfo" | sed 's/\..*//')"

  echo "$(pwd)""/""$filename" "$date" "$size" >>"$logfile"
}
