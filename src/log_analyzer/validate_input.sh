#!/bin/bash

# $1 - параметр из main.sh
# $2 - количество параметров из main.sh
function validate_input() {
  local result=0

  if ! [[ $2 -eq 1 && "$1" =~ ^[1-4]+$ ]]; then
    result=1
    echo "Script accepts exactly 1 parameter:"
    echo "1: records sorted by response code"
    echo "2: unique IP's"
    echo "3: error responses"
    echo "4: unique IP's with error responses"
  fi

  return $result
}
