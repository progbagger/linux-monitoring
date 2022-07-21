#!/bin/bash

# $1 - строка даты
# $2 - тип дат: "range" - диапазон дат, "date" - дата
# $3 - массив дат, записываются даты
function parse_dates() {
  local -n dates_arr
  dates_arr="$3"

  local date_type
  date_type="$2"

  local date_string
  date_string="$1"

  # Парсинг

  # Вытаскиваем день первой даты
  dates_arr+=("$(grep -Eo '^[0-9][0-9]' <<<"$date_string")")

  # Вытаскиваем месяц первой даты
  dates_arr+=("$(grep -Eo '^[0-9][0-9]\.?[0-9][0-9]' <<<"$date_string" | grep -Eo '[0-9][0-9]$')")

  # Вытаскиваем год первой даты
  if [[ "$date_type" == "date" ]]; then
    dates_arr+=("$(grep -Eo '[0-9][0-9]([0-9][0-9])?$' <<<"$date_string")")
  elif [[ "$date_type" == "range" ]]; then
    # Достаём год из первой даты и всё остальное из второй даты
    dates_arr+=("$(grep -Eo '[0-9][0-9]([0-9][0-9])?\-' <<<"$date_string" | sed 's/-//')")

    # Достаём день из второй даты
    dates_arr+=("$(grep -Eo '\-[0-9][0-9]' <<<"$date_string" | sed 's/\-//')")

    # Достаём месяц из второй даты
    dates_arr+=("$(grep -Eo '\-[0-9][0-9]\.?[0-9][0-9]' <<<"$date_string" | grep -Eo '[0-9][0-9]$')")

    # Достаём год из второй даты
    dates_arr+=("$(grep -Eo '[0-9][0-9]([0-9][0-9])?$' <<<"$date_string")")
  fi
}

arr=()
parse_dates "$1" "$2" arr
for el in "${arr[@]}"; do
  echo "$el"
done
