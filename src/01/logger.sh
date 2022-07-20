#!/bin/bash

function record() {
  # Имя логируемого файла
  local filename
  filename="$1"

  # Имя файла логов
  local logfile
  logfile="$2"

  # Тип файла: файл или директория
  local file_type
  file_type="$3"

  # Информация о файле
  local fileinfo
  fileinfo="$(ls -l --time-style=full-iso --block-size=K "$filename")"

  # Размер файла
  local size
  size="$(awk '{print $5}' <<<"$fileinfo")"

  # Дата создания файла
  local date
  date="$(awk '{print $6, _$7}' <<<"$fileinfo" | sed 's/\..*//')"

  # Логирование: файл или директория
  if [[ "$file_type" == "file" ]]; then
    echo "file ""$(pwd)""/""$filename" "$date" "$size" >>"$logfile"
  elif [[ "$file_type" == "folder" ]]; then
    echo "directory ""$(pwd)""/""$filename" >>"$logfile"
  fi
}
