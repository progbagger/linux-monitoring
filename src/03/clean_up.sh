#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./parse_dates.sh

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
    local check

    # Удаляем все файлы, записанные в логе
    while read -r line; do
      if [[ -f "$(awk '{print $2}' <<<"$line")" ]]; then
        files_count=$((files_count + 1))
      elif [[ -d "$(awk '{print $2}' <<<"$line")" ]]; then
        local files_in_dir
        files_in_dir=$(ls "$(awk '{print $2}' <<<"$line")" | wc -w)
        files_count=$((files_count + 1 + files_in_dir))
      fi
      rm -rf "$(awk '{print $2}' <<<"$line")"
    done <"$info"
  elif [[ "$file_type" == "date" ]]; then

    # Парсим дату
    local dates_array=()
    parse_dates "$info" "range" dates_array

    # Ищем ФАЙЛЫ в указанном диапазоне и удаляем их
    # ! Если удалять папки, есть риск лишиться многого!
    local files
    files="$(find ~ -type f -newermt "${dates_array[2]}-${dates_array[1]}-${dates_array[0]} ${dates_array[3]}:${dates_array[4]}" ! -newermt "${dates_array[7]}-${dates_array[6]}-${dates_array[5]} ${dates_array[8]}:${dates_array[9]}" 2>/dev/null)"
    files+="$(find /tmp -type f -newermt "${dates_array[2]}-${dates_array[1]}-${dates_array[0]} ${dates_array[3]}:${dates_array[4]}" ! -newermt "${dates_array[7]}-${dates_array[6]}-${dates_array[5]} ${dates_array[8]}:${dates_array[9]}" 2>/dev/null)"
    local str_count
    str_count="$(wc -l <<<"$files")"
    if [[ $str_count -gt 100 ]]; then
      echo -en "$red""There are more than 100 files ($str_count). Show them? [Y/n]: ""$reset""$green"
      local answer
      read -rn 1 answer
      echo -e "$reset"
      if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
        echo -e "$purple""$files""$reset"
      fi
    else
      echo -e "$purple""$files""$reset"
    fi
    echo -e "$red""BE CAREFUL!!! THERE MAY BE SOME SYSTEM FILES!""$reset"
    echo -e "$green""Note that there only files in case of probability of deleting user folder""$reset"
    echo -en "$red""Delete these ""$reset""$purple""$(wc -l <<<"$files")""$reset""$red"" files? [Y/n]: ""$reset""$green"
    read -rn 1 answer
    echo -e "$reset"
    if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
      for el in $files; do
        local ftype
        if [[ -f "$el" ]]; then
          ftype="file"
        else
          ftype="err"
        fi

        rm -rf "$el" >/dev/null
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
