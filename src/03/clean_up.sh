#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./parse_dates.sh
source ./validate_log_line.sh

# $1 - информация для удаления
# $2 - тип информации для удаления
function clean_up() {
  # Создаём цвета
  local red="\033[31;m"
  local purple="\033[35;m"
  local reset="\033[m"

  local file_type
  file_type="$2"

  local info
  info="$1"

  if [[ "$file_type" == "file" ]]; then
    # Считаем номер строчки
    local line_count
    line_count=1

    # Удаляем все файлы, записанные в логе
    while read -r line; do
      if [[ $(validate_log_line "$line") -eq 0 ]]; then
        rm -rf "$(awk '{print $2}' <<<"$line")"
      else
        echo "$red""Line ""$reset""$purple""$line_count""$reset""$red"" is incorrect. Ignoring it.""$reset"
      fi
    done <<<"$info"
  elif [[ "$file_type" == "range" ]]; then

    # Парсим дату
    local dates_arr=()
    parse_dates "$info" "range" dates_arr

    # Создаём список всех файлов, подходящих под данный диапазон

  elif [[ "$file_type" == "mask" ]]; then
  fi
}
