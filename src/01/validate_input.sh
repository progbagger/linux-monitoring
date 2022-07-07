#!/bin/bash

validate_input() {
  result=0

  if [[ $7 -ne 6 ]]; then
    echo "This script must be executed with exactly 6 parameters."
    result=1
  else
    if [[ -d "$1" ]]; then
      echo "- 1-st param: This folder is already exist."
      result=1
    fi
    if ! [[ "$2" =~ [[:digit:]] && $2 -ge 0 ]]; then
      echo "- 2-nd param: Must be a non-negative number."
      result=1
    fi
    if ! [[ "$3" =~ [[:alpha:]] && ${#3} -le 7 && ${#3} -gt 0 ]]; then
      echo "- 3-rd param: Must consist of English alphabet and have length of 7 characters."
      result=1
    fi
    if ! [[ "$4" =~ [[:digit:]] && $4 -gt 0 ]]; then
      echo "- 4-th param: Must be a positive number."
      result=1
    fi
    name="$(grep -oE '^.*\.' <<<"$5" | sed 's/\.//')"
    extension="$(grep -oE '\..*$' <<<"$5" | sed 's/\.//')"
    if ! [[ "$name" =~ [[:alpha:]] && ${#name} -le 7 && "$extension" =~ [[:alpha:]] && ${#extension} -le 3 ]]; then
      echo "- 5-th param: Must be in format \"abcdefg.abc\"."
      result=1
    fi
    value="$(grep -oE '^[[:digit:]].*(kb)' <<<"$6" | sed 's/kb//')"
    if ! [[ $value -gt 0 && $value -le 100 ]]; then
      echo "- 6-th param: Must be in format nkb, 0 < n <= 100."
      result=1
    fi
  fi
  if [[ $result -eq 1 ]]; then
    echo "Please, try again."
  fi
  return $result
}
