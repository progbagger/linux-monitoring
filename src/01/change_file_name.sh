#!/bin/bash

function change_file_name() {
  local -n current_file_name
  local -n current_file_extension
  local available_names
  local available_extensions

  current_file_name="$1"
  current_file_extension="$2"
  available_names="$3"
  available_extensions="$4"

  # Изменяем имя файла
  if [[ "$current_file_name" == "" ]]; then
    for letter in $available_names; do
      current_file_name+="$letter"
    done
    while [[ ${#current_file_name} -lt 4 ]]; do
      current_file_name+="${available_names: -1}"
    done
  else
    current_file_name+="${available_names: -1}"
  fi

  # Изменяем расширение файла
  if [[ "$current_file_extension" == "" ]]; then
    for letter in $available_extensions; do
      current_file_extension+="$letter"
    done
  else
    current_file_extension+="${available_extensions: -1}"
  fi
}
