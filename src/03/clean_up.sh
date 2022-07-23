#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./parse_dates.sh
source ./validate_log_line.sh

# $1 - информация для удаления
# $2 - тип информации для удаления
function clean_up() {
  # Создаём цвета
  local red="\033[91m"
  local purple="\033[95m"
  local green="\033[92m"
  local reset="\033[m"

  local file_type
  file_type="$2"

  local info
  info="$1"

  # Счётчик
  local files_count=0

  if [[ "$file_type" == "file" ]]; then
    # Считаем номер строчки
    local line_count
    line_count=1

    # Удаляем все файлы, записанные в логе
    while read -r line; do
      if [[ $(validate_log_line "$line") -eq 0 ]]; then
        if [[ -f "$(awk '{print $2}' <<<"$line")" ]]; then
          files_count=$((files_count + 1))
        fi
        rm -rf "$(awk '{print $2}' <<<"$line")"
      else
        echo "$red""Line ""$reset""$purple""$line_count""$reset""$red"" is incorrect. Ignoring it.""$reset"
      fi
    done <"$info"
  elif [[ "$file_type" == "date" ]]; then

    # Парсим дату
    local dates_arr=()
    parse_dates "$info" "range" dates_arr

    # Ищем ФАЙЛЫ в указанном диапазоне и удаляем их
    # ! Если удалять папки, есть риск лишиться многого!
    local files
    files="$(find ~ -type f -newermt "${dates_arr[2]}-${dates_arr[1]}-${dates_arr[0]} ${dates_arr[3]}:${dates_arr[4]}" ! -newermt "${dates_arr[7]}-${dates_arr[6]}-${dates_arr[5]} ${dates_arr[9]}:${dates_arr[8]}")"
    files+="$(find /tmp -type f -newermt "${dates_arr[2]}-${dates_arr[1]}-${dates_arr[0]} ${dates_arr[3]}:${dates_arr[4]}" ! -newermt "${dates_arr[7]}-${dates_arr[6]}-${dates_arr[5]} ${dates_arr[9]}:${dates_arr[8]}")"
    echo "$red""Delete these ""$reset""$purple""$(wc -l <<<"$files")""$reset""$red"" files? [Y/n]""$reset"
    local answer
    read -rn 1 answer
    if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
      for el in $files; do
        local ftype
        if [[ -f "$el" ]]; then
          ftype="file"
        else
          ftype="err"
        fi

        rm -rf "$el" >/dev/null
        local check
        check=$?

        # Считаем удалённые файлы
        if [[ $check -eq 0 ]]; then
          if [[ "$ftype" == "file" ]]; then
            files_count=$((files_count + 1))
          fi
        fi
      done
    fi
  elif [[ "$file_type" == "mask" ]]; then
    local names
    names="$(grep -Eo '^.*_' <<<"$info" | sed 's/_//')"

    local dates
    dates="$(grep -Eo '[0-9][0-9][0-9][0-9][0-9][0-9]' <<<"$info")"

    local exts
    exts="$(grep -Eo '\..*$' <<<"$info" | sed 's/\.//')"

    # Строим регулярное выражение имён наших файлов
    local reg_names
    reg_names=".*/[$names]+""_""$dates"
    if [[ "$exts" != "" ]]; then
      reg_names+=".?[$exts]+?$"
    fi

    # Ищем нужные файлы
    local files
    files="$(find ~ -regex "$reg_names" 2>/dev/null)"
    files+="$(find /tmp -regex "$reg_names" 2>/dev/null)"

    # Удаляем...
    for el in $files; do
      rm -rf "$el" >/dev/null
      local check
      check=$?

      if [[ $check -eq 0 ]]; then
        files_count=$((files_count + 1))
      fi
    done
  fi

  # Выводим итоги
  echo -e "$green""Done""$reset"
  echo -e "$green""Files deleted: ""$reset""$red""$files_count""$reset"
}
