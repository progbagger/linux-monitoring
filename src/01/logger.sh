#!/bin/bash

# $1 - имя логируемого файла
# $2 - имя файла с логами
# $3 - тип файла: директория или файл
function record() {
  local filename
  filename="$1"

  local logfile
  logfile="$2"

  local file_type
  file_type="$3"

  # Информация о файле
  local fileinfo
  fileinfo="$(ls -l '--time-style=+%Y-%M-%d %H:%M:%S' --block-size=K "$filename")"

  # Размер файла
  local size
  size="$(awk '{print $5}' <<<"$fileinfo")"

  # Дата создания файла
  local date
  date="$(awk '{print $6, _$7}' <<<"$fileinfo" | sed 's/\..*//')"

  # Логирование: файл или директория
  if [[ "$file_type" == "file" ]]; then
    echo "file      ""$(pwd)""/""$filename" "$date" "$size" >>"$logfile"
  elif [[ "$file_type" == "folder" ]]; then
    echo "directory ""$(pwd)""/""$filename" >>"$logfile"
  fi
}
