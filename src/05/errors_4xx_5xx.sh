#!/bin/bash

# $1 - содержимое логов
function error_requests() {
  local content="$1"

  # Достаём ошибочные ответы
  while read -r record; do
    local response_code
    response_code="$(awk '{print $2}' <<<"$record")"

    if [[ "${response_code:0:1}" == "4" || "${response_code:0:1}" == "5" ]]; then
      echo "$record"
    fi
  done <<<"$content"
}
