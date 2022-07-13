#!/bin/bash

function change_folder_name() {
  local -n current_folder_name
  current_folder_name="$1"

  local available_names
  available_names="$2"

  if [[ "$current_folder_name" == "" ]]; then
    for letter in $available_names; do
      current_folder_name+="$letter"
    done
    while [[ ${#current_folder_name} -lt 4 ]]; do
      current_folder_name+="${available_names: -1}"
    done
  else
    current_folder_name+="${available_names: -1}"
  fi
}
