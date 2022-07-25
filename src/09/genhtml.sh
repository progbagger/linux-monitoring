#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./scrap_metrics.sh

# $1 - размер табуляции
# $2 - текст
function tabulate() {
  for ((i = 0; i < $1 * 2; i++)); do
    echo -n " "
  done
  echo "$2"
}

# Функция для добавления в массив строк из переменной
# $1 - переданный массив
# $2 - переменная
function append() {
  local -n arr
  arr="$1"

  while read -r line; do
    arr+=("$line")
  done <<<"$2"
}

# $1 - путь к результирующему HTML-файлу
function genhtml() {
  local result=()

  # append result "$(tabulate 0 "<html>")"
  # append result "$(tabulate 1 "<head>")"
  # append result "$(tabulate 2 "<meta name=\"color-scheme\" content=\"light dark\">")"
  # append result "$(tabulate 1 "</head>")"
  # append result "$(tabulate 1 "<body>")"
  # append result "$(tabulate 2 "<pre style=\"word-wrap: break-word; white-space: pre-wrap;\">")"

  # Получаем инфу
  local system_info
  system_info="$(scrap)"

  # Каждую строку выводим с табуляцией для корректного отображения в HTML-документе
  while read -r line; do
    append result "$(tabulate 3 "$line")"
  done <<<"$system_info"

  # # Закрываем теги
  # append result "$(tabulate 2 "</pre>")"
  # append result "$(tabulate 1 "</body>")"
  # append result "$(tabulate 0 "</html>")"

  # Удаляем предыдущие метрики
  echo -n "" >"$1"

  for line in "${result[@]}"; do
    echo "$line" >>"$1"
  done
}
