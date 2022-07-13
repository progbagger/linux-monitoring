#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

# $1 - путь к папке
# $2 - количество подпапок
# $3 - строка символов допустимых букв в названиях подпапок
# $4 - количество создаваемых файлов в каждой подпапке
# $5 - строка символов допустимых букв в названиях файлов
# $6 - размер одного создаваемого файла вида 50kb

source ./validate_input.sh
source ./thrashification.sh

validate_input "$1" "$2" "$3" "$4" "$5" "$6" $#
check=$?
if [[ $check -eq 0 ]]; then
  folder="$1"
  if [[ $(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//') -ge 1024 ]]; then
    mkdir -p "$folder"
    party_hard "$2" "$3" "$4" "$5" "$6" "$folder"
  else
    echo "There is already less free space than 1GB."
    check=1
  fi
fi
exit $check
