#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ../01/change_file_name.sh
source ../01/generate_file.sh
source ../01/logger.sh

function party_hard() {
  # Доступные символы имени папок
  local available_folders_names
  available_folders_names="$1"

  # Доступные символы имени файлов
  local available_files_names
  available_files_names="$(grep -Eo '.*\.' <<< "$2" | sed 's/\.//')"
  
  # Доступные символы расширений
  local extension
  extension="$(grep -Eo '\..*' <<< "$2" | sed 's/\.//')"

  # Размер создаваемых файлов
  local size
  size="$(sed 's/Mb//' <<< "$3")"

  # Список путей, куда можно создавать файлы
  local folders_list
  folders_list=(
    "$HOME/"
    "/tmp/"
  )


}