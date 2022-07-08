#!/bin/bash
# shellcheck disable=SC1091

# $1 - путь к папке
# $2 - количество подпапок
# $3 - строка символов допустимых букв в названиях подпапок
# $4 - количество создаваемых файлов в каждой подпапке
# $5 - строка символов допустимых букв в названиях файлов
# $6 - размер одного создаваемого файла

source ./validate_input.sh
source ./thrashification.sh

validate_input "$1" "$2" "$3" "$4" "$5" "$6" $#
check=$?
if [[ $check -eq 0 ]]; then
  folder="$1"
  mkdir -p "$folder"
  cd "$folder" || exit 1
  party_hard 
fi
exit $check
