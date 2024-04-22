#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

# $1 - строка символов допустимых букв в названиях подпапок
# $2 - строка символов допустимых букв в названиях файлов
# $3 - размер одного создаваемого файла вида 50Mb

relative_path="$(dirname "$0")"

source "$relative_path"/validate_input.sh
source "$relative_path"/thrashification.sh

# Валидация параметров
validate_input "$1" "$2" "$3" $#
check=$?

if [[ $check -eq 0 ]]; then
  # Если места уже не хватает, выдать соответствующее сообщение
  if [[ "$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//')" -ge 1024 ]]; then
    party_hard "$1" "$2" "$3"
  else
    echo "There is already less free space than 1GB."
    check=1
  fi
fi
exit $check
