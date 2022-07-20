#!/bin/bash

# $1 - символы имён поддиректорий
# $2 - символы имён файлов
# $3 - размер в мегабайтах
# $4 - количество аргументов, переданных в main.sh
validate_input() {
  local result
  result=0

  if [[ $4 -ne 3 ]]; then
    echo "This script must be executed with exactly 3 parameters."
    result=1
  else
    if ! [[ "$1" =~ [[:alpha:]] && ${#1} -le 7 && ${#1} -gt 0 ]]; then
      echo "- 1-st param: Must consist of English alphabet and have length of 7 characters."
      result=1
    fi

    local name
    name="$(grep -oE '^.*\.' <<<"$2" | sed 's/\.//')"

    local extension
    extension="$(grep -oE '\..*$' <<<"$2" | sed 's/\.//')"

    if ! [[ "$name" =~ [[:alpha:]] && ${#name} -le 7 && "$extension" =~ [[:alpha:]] && ${#extension} -le 3 ]]; then
      echo "- 2-nd param: Must be in format \"abcdefg.abc\"."
      result=1
    fi

    local value
    value="$(grep -oE '^[[:digit:]].*(Mb)' <<<"$3" | sed 's/Mb//')"

    if ! [[ $value -gt 0 && $value -le 100 ]]; then
      echo "- 3-rd param: Must be in format nMb, 0 < n <= 100."
      result=1
    fi
  fi
  if [[ $result -eq 1 ]]; then
    echo "Please, try again."
  fi
  return $result
}
