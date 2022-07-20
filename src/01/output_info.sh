#!/bin/bash

RESET="\033[0m"
CYAN="\033[96m"
RED="\033[91m"

previous_space_string=""

# $1 - оставшееся свободное место в формате числа
function output_space_at_start() {
  local avail_space_print="$1"" MB"
  echo -e "$CYAN""Space at start: ""$RESET""$RED""$avail_space_print""$RESET"
  echo -en "$CYAN""Current space available: ""$RESET"
  local tail="$RED""$avail_space_print""$RESET"
  previous_space_string="$avail_space_print"
  echo -en "$tail"
}

# $1 - оставшееся свободное место в формате числа
function output_current_space() {
  # Убираем текущее место
  for ((i = 0; i < ${#previous_space_string}; i++)); do
    echo -ne "\b"
  done

  # Печатаем новое место
  local avail_space_print="$1"" MB"
  echo -ne "$RED""$avail_space_print""$RESET"
  previous_space_string="$avail_space_print"
}

# $1 - общее количество созданных папок
# $2 - общее количество созданных файлов
function output_results() {
  echo
  echo -e "$CYAN""Done""$RESET"
  echo -e "$RED""$1""$RESET"" ""$CYAN""folders created""$RESET"
  echo -e "$RED""$2""$RESET"" ""$CYAN""files created""$RESET"
}
