#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./validate_input.sh
source ./clean_up.sh

info="$1"
result=0
parameter_type=""

validate_input "$info" parameter_type $#
result=$?

if [[ $result -eq 0 ]]; then
  clean_up "$info" "$parameter_type"
fi

exit $result
