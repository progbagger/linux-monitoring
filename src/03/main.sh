#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./validate_input.sh

path_to_log="$1"
result=0

if [[ -f "$path_to_log" ]]; then
  while read -r line; do
    rm -rf "$(awk '{print $2}' <<<"$line")"
  done <"$path_to_log"
  rm -rf "$path_to_log"
else
  echo "Incorrect path to log"
  result=1
fi
exit $result
