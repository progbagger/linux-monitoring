#!/bin/bash

# $1 - путь к файлам логов
function get_logs_contents() {
  local files
  files="$(ls "$1")"

  local files_str=""

  local content=""

  # Перебираем все файлы
  for file in $files; do
    files_str+="$1/$file "
  done

  # Получаем содержимое файлов с помощью cat
  content="$(cat $files_str)"

  echo "$content"
}
