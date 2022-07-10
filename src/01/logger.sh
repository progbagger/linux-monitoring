#!/bin/bash

logfile="created_files.log"

# Имя файла должно быть абсолютным!
function record() {
  filename="$1"
  fileinfo="$(ls -l --time-style=full-iso --block-size=K "$filename")"
  size="$(awk '{print $5}' <<<"$fileinfo")"
  date="$(awk '{print $6, _$7}' <<<"$fileinfo" | sed 's/\..*//')"
  echo "$filename" "$date" "$size" >>"$logfile"
}
