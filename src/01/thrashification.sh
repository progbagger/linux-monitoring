#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./logger.sh
source ./generate_file.sh
source ./change_folder_name.sh
source ./change_file_name.sh

function party_hard() {
  local logfile_name
  logfile_name="$(pwd)/created_files.log"

  local folder
  folder="$6"

  cd "$folder" || exit 1

  # Необходимые переменные
  current_date="$(date '+%d%m%y')"

  # Количество подпапок
  local subfolders_total
  subfolders_total=$1

  # Допустимые имена папок
  local folders_names_letters
  folders_names_letters="$2"

  # Начальное имя подпапки
  local current_subfolder
  current_subfolder=""

  # Количество файлов в каждой папке
  local files_total
  files_total=$3

  # Допустимые имена файлов вместе с расширениями
  local filenames
  filenames="$4"

  # Допустимые имена файлов
  local files_names_letters
  files_names_letters="$(grep -oE '.*\.' <<<"$filenames" | sed 's/\.//')"

  # Допустимые расширения файлов
  local files_extensions_letters
  files_extensions_letters="$(grep -oE '\..*' <<<"$filenames" | sed 's/\.//')"

  # Начальное имя файла
  local current_filename
  current_filename=""

  # Начальное расширение файла
  local current_extension
  current_extension=""

  # Размер каждого файла
  local file_size
  file_size="$5"
  file_size=$(grep -oE '^[[:digit:]].*(kb)' <<<"$file_size" | sed 's/kb//')

  # Сама генерация

  local avail_space
  avail_space=$(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//')

  local avail_space_print="$avail_space"" MB"

  local RESET="\033[0m"
  local CYAN="\033[96m"
  local RED="\033[91m"
  echo -en "$CYAN""Space available: ""$RESET"
  local tail="$RED""$avail_space_print""$RESET"
  echo -en "$tail"
  while [[ $avail_space -ge 1024 ]]; do
    for ((subfolder_count = 0; subfolder_count < subfolders_total; subfolder_count++)); do
      change_folder_name current_subfolder "$folders_names_letters"
      mkdir "$current_subfolder""_""$current_date"
      cd "$current_subfolder""_""$current_date" || exit 1
      for ((file_count = 0; file_count < files_total; file_count++)); do
        change_file_name current_filename current_extension "$files_names_letters" "$files_extensions_letters"
        genfile "$current_filename""_""$current_date"".""$current_extension" "$file_size"
        record "$current_filename""_""$current_date"".""$current_extension" "$logfile_name"
      done
      if [[ $subfolder_count -ne $((subfolders_total - 1)) ]]; then
        cd ..
      fi
      current_filename=""
      current_extension=""
      change_folder_name current_subfolder "$folders_names_letters"
    done
    current_subfolder=""
    avail_space=$(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//')
    avail_space_print="$avail_space"" MB"
    echo -en "\033[""${#avail_space_print}""D"
    tail="$RED""$avail_space_print""$RESET"
    echo -en "$tail"
  done
  echo
  echo -e "$CYAN""Done""$RESET"
}
