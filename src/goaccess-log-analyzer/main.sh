#!/bin/bash

relative_path="$(dirname "$0")"

if [[ $# -ne 1 ]]; then
  echo "Specify path to logs folder"
  exit 1
fi

if ! [[ -d "$1" ]]; then
  echo "Path \"$1\" is not a directory"
  exit 1
fi

# Путь к файлам лога
path_to_logs="$1"

# Название файла конфигурации для GoAccess
goaccess_conf="$relative_path/goaccess.conf"

param=""

result=0

if [[ $# -ge 1 ]]; then

  # Создаём строку файлов для конфа
  files="$(ls "$path_to_logs")"
  for file in $files; do
    param+="$path_to_logs/$file "
  done

  goaccess -p "$goaccess_conf" $param -o stats.html
  goaccess -p "$goaccess_conf" $param
fi

exit $result
