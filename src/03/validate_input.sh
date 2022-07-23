#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./parse_dates.sh

# $1 - параметр из main.sh
# $2 - тип параметра, который нужно вернуть
# $3 - количество переданных в main.sh параметров
function validate_input() {
  local result=0

  local -n param_type
  param_type="$2"

  # Регулярное выражение для проверки корректности ввода даты
  local date_mask
  date_mask="^([0][1-9]|[1-2][0-9]|3[0-1]|)\.(0[1-9]|1[0-2])\.([0-9][0-9]([0-9][0-9])?) ([0-1][0-9]|2[0-3]):[0-5][0-9] ?- ?([0][1-9]|[1-2][0-9]|3[0-1]|)\.(0[1-9]|1[0-2])\.([0-9][0-9]([0-9][0-9])?) ([0-1][0-9]|2[0-3]):[0-5][0-9]$"

  if [[ $3 -ne 1 ]]; then
    echo "This script must be executed with exactly 1 parameter:"
    echo "- exact path to the file (relative or absolute)"
    echo "  or"
    echo "- range of dates of creation (e.g. \"01.12.84 23:59:59 - 01.06.03 12:30:45\")"
    echo "  or"
    echo "- name mask (e.g. abcdefg_220684.abc)"
    echo
    echo "Please, rerun the script with appropriate parameter."
    result=1
  else
    local file_mask="^[[:lower:]]{1,7}_([0][1-9]|[1-2][0-9]|3[0-1]|)(0[1-9]|1[0-2])([0-9][0-9])"

    # Проверка на файл логов
    if [[ -f "$1" ]]; then
      param_type="file"

    # Проверка на маску имён
    elif [[ "$1" =~ $date_mask ]]; then

      # Парсинг дат для их дальнейшей проверки
      local check
      parse_dates "$1" "range" dates
      check=$?

      if [[ $check -eq 0 ]]; then
        param_type="date"
      else
        param_type="date error"
        result=1
      fi

    # Проверка на диапазон дат
    elif [[ "$1" =~ $file_mask ]]; then

      # Парсинг дат для их дальнейшей проверки
      local inputed_date
      inputed_date="$(grep -Eo '_.*$' <<<"$1" | sed 's/_//')"

      parse_dates "$inputed_date" "date" dates
      check=$?

      if [[ $check -eq 0 ]]; then
        param_type="mask"
      else
        param_type="mask error"
        result=1
      fi
    else
      echo "Parameter is not valid. Please, try again."
      result=1
    fi
  fi

  return $result
}

param=""
validate_input "$1" param "$3"
check=$?

echo "param_type = $param"
echo "check = $check"
