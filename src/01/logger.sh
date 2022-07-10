#!/bin/bash

filename="$1"
logfile="created_files.log"

function record() {
  fileinfo="$(ls -l --time-style=full-iso --block-size=K "$filename")"
  size="$(awk '{print $5}' <<<"$fileinfo")"
  date="$(awk '{print $6, _$7}' <<<"$fileinfo" | sed 's/\..*//')"
  echo "$filename" "$date" "$size" >>"$logfile"
}

record "$filename"
