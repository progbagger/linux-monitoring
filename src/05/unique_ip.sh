#!/bin/bash

# $1 - содержимое файлов логов
function unique_ips() {
  local content="$1"

  local output=""

  # Выдёргиваем все уникальные IP
  output="$(awk '{print $1}' <<<"$content" | sort -u)"

  echo "$output"
}
