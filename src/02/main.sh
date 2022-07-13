#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

# $1 - строка символов допустимых букв в названиях подпапок
# $2 - строка символов допустимых букв в названиях файлов
# $3 - размер одного создаваемого файла вида 50Mb

source ./validate_input.sh
source ../01/logger.sh
source ../01/change_folder_name
source ../01/change_file_name

validate_input "$1" "$2" "$3" $#
check=$?

if [[ $check -eq 0 ]]; then

fi
exit $check
