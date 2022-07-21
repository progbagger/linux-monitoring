#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./logger.sh
source ./generate_file.sh
source ./change_file_name.sh
source ./output_info.sh

# $1 - количество подпапок
# $2 - допустимые символы имён папок
# $3 - количество файлов
# $4 - допустимые имена файлов
# $5 - размер создаваемых файлов
# $6 - директория, в которой создавать подпапки
function party_hard() {
  # Имя файла с логами
  local logfile_name
  logfile_name="$(dirname "$0")/created_files.log"

  local folder
  folder="$6"

  cd "$folder" || exit 1

  # Дата запуска скрипта
  current_date="$(date '+%d%m%y')"

  local subfolders_total
  subfolders_total="$1"

  local folders_names_letters
  folders_names_letters="$2"

  local current_subfolder
  current_subfolder=""

  local files_total
  files_total="$3"

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

  local file_size
  file_size="$5"
  file_size=$(grep -oE '^[[:digit:]].*(kb)' <<<"$file_size" | sed 's/kb//')

  # Сама генерация

  # Обнаружение доступного места
  local avail_space
  avail_space=$(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//')

  # Печать свободного места на экран
  output_space_at_start "$avail_space"

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

      # Печатаем место на экран
      output_current_space "$avail_space"
    done

    # Возвращаемся на уровень выше для продолжения работы скрипта
    cd ..
    current_filename=""
  done

  # Выводим итог работы скрипта
  output_results "$total_folders_created" "$total_files_created"
}
