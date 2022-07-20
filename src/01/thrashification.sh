#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./logger.sh
source ./generate_file.sh
source ./change_file_name.sh

function party_hard() {
  # Имя файла с логами
  local logfile_name
  logfile_name="$(pwd)/created_files.log"

  # Папка, указанная пользователем
  local folder
  folder="$6"

  cd "$folder" || exit 1

  # Дата запуска скрипта
  current_date="$(date '+%d%m%y')"

  # Количество подпапок
  local subfolders_total
  subfolders_total="$1"

  # Допустимые имена папок
  local folders_names_letters
  folders_names_letters="$2"

  # Начальное имя подпапки
  local current_subfolder
  current_subfolder=""

  # Количество файлов в каждой папке
  local files_total
  files_total="$3"

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

  # Размер каждого файла
  local file_size
  file_size="$5"
  file_size=$(grep -oE '^[[:digit:]].*(kb)' <<<"$file_size" | sed 's/kb//')

  # Сама генерация

  # Обнаружение доступного места
  local avail_space
  avail_space=$(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//')

  local avail_space_print="$avail_space"" MB"

  # Печать свободного места на экран
  local RESET="\033[0m"
  local CYAN="\033[96m"
  local RED="\033[91m"
  echo -e "$CYAN""Space at start: ""$RESET""$RED""$avail_space_print""$RESET"
  echo -en "$CYAN""Current space available: ""$RESET"
  local tail="$RED""$avail_space_print""$RESET"
  echo -en "$tail"

  # Счётчики созданных папок и файлов
  local folders_count=0
  local total_files_created=0
  local total_folders_created=0

  # Непосредственно сорение
  while [[ $avail_space -ge 1024 && $folders_count -lt $subfolders_total ]]; do
    local files_count=0

    # Меняем имя папки
    change_file_name current_subfolder "$folders_names_letters" "4"
    mkdir "$current_subfolder""_""$current_date"

    # Логируем имя созданной папки
    record "$current_subfolder""_""$current_date" "$logfile_name" "folder"
    folders_count=$((folders_count + 1))
    total_folders_created=$((total_folders_created + 1))

    # Переходим в созданную папку
    cd "$current_subfolder""_""$current_date" || exit 1

    # Создаём файлы в папке пока не кончится место или пока не создастся
    # нужное количество
    while [[ $avail_space -ge 1024 && $files_count -lt $files_total ]]; do
      change_file_name current_filename "$files_names_letters" "4"
      genfile "$current_filename""_""$current_date"".""$files_extensions_letters" "$file_size" "K"
      files_count=$((files_count + 1))
      total_files_created=$((total_files_created + 1))

      # Логируем созданный файл
      record "$current_filename""_""$current_date"".""$files_extensions_letters" "$logfile_name" "file"

      # Обновляем свободное место
      avail_space=$(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//')
      for ((i = 0; i < ${#avail_space_print}; i++)); do
        echo -ne "\b"
      done

      # Печатаем место на экран
      avail_space_print="$avail_space"" MB"
      echo -ne "$RED""$avail_space_print""$RESET"
    done

    # Возвращаемся на уровень выше для продолжения работы скрипта
    cd ..
    current_filename=""
  done

  # Выводим итог работы скрипта
  echo
  echo -e "$CYAN""Done""$RESET"
  echo -e "$RED""$total_folders_created""$RESET"" ""$CYAN""folders created""$RESET"
  echo -e "$RED""$total_files_created""$RESET"" ""$CYAN""files created""$RESET"
}
