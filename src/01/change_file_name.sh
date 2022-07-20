#!/bin/bash

name_prefix=""

function change_file_name() {
  local -n current_file_name
  local available_names
  local min_length

  # Текущее имя файла или папки
  current_file_name="$1"

  # Строка доступных символов имени файла или папки
  available_names="$2"

  # Минимальная длина имени файла или папки
  min_length="$3"

  # Изменяем имя файла или папки
  if [[ "$current_file_name" == "" ]]; then
    current_file_name="$available_names"
    while [[ ${#current_file_name} -lt $min_length ]]; do
      current_file_name+="${available_names: -1}"
    done
  else
    current_file_name+="${available_names: -1}"
  fi

  # Если имя файла или папки превышает допустимое, добавляем в начало букву начала
  if [[ ${#current_file_name} -ge $((256 - 7 - 1 - 3)) ]]; then
    name_prefix+="${available_names:0:1}"
    current_file_name="$name_prefix""$available_names"
    while [[ ${#current_file_name} -lt $min_length ]]; do
      current_file_name+="${available_names: -1}"
    done
  fi
}
