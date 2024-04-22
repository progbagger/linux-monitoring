#!/bin/bash

# Путь к файлам лога
path_to_logs="../04/nginx_logs"

# Название файла конфигурации для GoAccess
goaccess_conf="goaccess.conf"

param=""

result=0

if [[ $# -eq 0 ]]; then

  # Создаём строку файлов для конфа
  files="$(ls "$path_to_logs")"
  for file in $files; do
    param+="$path_to_logs/$file "
  done

  goaccess -p "$goaccess_conf" $param -o stats.html
  goaccess -p "$goaccess_conf" $param
else
  result=1
  echo "Script does not accepts any parameters."
fi

exit $result
