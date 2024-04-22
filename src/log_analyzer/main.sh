#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

relative_path="$(dirname "$0")"

source "$relative_path"/response.sh
source "$relative_path"/unique_ip.sh
source "$relative_path"/errors_4xx_5xx.sh
source "$relative_path"/validate_input.sh
source "$relative_path"/get_logs_content.sh

red="\033[91m"
reset="\033[m"

validate_input "$1" $2 $#
check=$?

# Путь к логам
logs_path="$1"

result=0

if [[ $check -eq 0 && -d "$logs_path" ]]; then
  logs_content="$(get_logs_contents "$logs_path")"
  if [[ $2 -eq 1 ]]; then
    output="$(sort_by_response_codes "$logs_content")"
  elif [[ $2 -eq 2 ]]; then
    output="$(unique_ips "$logs_content")"
  elif [[ $2 -eq 3 ]]; then
    echo -e "$red""Processing...""$reset"

    output="$(error_requests "$logs_content")"
  elif [[ $2 -eq 4 ]]; then
    echo -e "$red""Processing...""$reset"

    # Сначала получаем все запросы с ошибками
    output="$(error_requests "$logs_content")"

    # Затем получаем из них уникальные IP
    output="$(unique_ips "$output")"
  fi

  echo "$output"
elif [[ $check -ne 0 ]]; then
  result=1
else
  result=2
  echo "There is no directory with logs at path \"$logs_path\". Abort."
fi

exit $result
