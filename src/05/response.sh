#!/bin/bash

# $1 - все записи логов
function sort_by_response_codes() {
  local output=""

  local content="$1"

  # Сортируем
  output="$(sort -k 2 <<<"$content")"

  echo "$output"
}
