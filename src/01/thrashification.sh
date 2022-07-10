#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./logger.sh
source ./generate_file.sh

function party_hard() {
  subfolders_total=$1
  folders_names_letters="$2"
  current_subfolder="${folders_names_letters:0:1}"
  files_total=$3
  filenames="$4"
  files_names_letters="$(grep -oE '.*\.' | sed 's/\.//')"
  files_extensions-letters="$(grep -oE '\..*' | sed 's/\.//')"
  current_filename="${files_names_letters}"
  file_size=$(grep -oE '^[[:digit:]].*(kb)' <<<"$5" | sed 's/kb//')
  while [[ $(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//') -ge 1024 ]]; do

  done
}
