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

  # Возвращаемое значение, указывающее на ошибку в датах
  local result=0

  # Парсинг

  # Вытаскиваем день первой даты
  dates_arr+=("$(grep -Eo '^[0-9][0-9]' <<<"$date_string")")

  # Вытаскиваем месяц первой даты
  dates_arr+=("$(grep -Eo '^[0-9][0-9]\.[0-9][0-9]' <<<"$date_string" | grep -Eo '[0-9][0-9]$')")

  # Вытаскиваем год первой даты
  if [[ "$date_type" == "date" ]]; then
    dates_arr+=("$(grep -Eo '[0-9][0-9]([0-9][0-9])?$' <<<"$date_string")")
  elif [[ "$date_type" == "range" ]]; then

    # Достаём год из первой даты и всё остальное из второй даты
    dates_arr+=("$(grep -Eo '[0-9][0-9]([0-9][0-9])? [0-9]' <<<"$date_string" | head -1 | sed 's/ [0-9]$//')")

    # Достаём время из первой даты
    local time_str
    time_str="$(grep -Eo '[0-9][0-9]:[0-9][0-9] ?-' <<<"$date_string" | sed 's/ -//; s/-//')"
    echo "$time_str"

    # Достаём часы из первой даты
    dates_arr+=("$(grep -Eo '^[0-9][0-9]' <<<"$time_str")")

    # Достаём минуты из первой даты
    dates_arr+=("$(grep -Eo '[0-9][0-9]$' <<<"$time_str")")

    # Достаём день из второй даты
    dates_arr+=("$(grep -Eo '\- ?[0-9][0-9]' <<<"$date_string" | sed 's/- //; s/-//')")

    # Достаём месяц из второй даты
    dates_arr+=("$(grep -Eo '\- ?[0-9][0-9]\.[0-9][0-9]' <<<"$date_string" | grep -Eo '[0-9][0-9]$')")

    # Достаём год из второй даты
    dates_arr+=("$(grep -Eo '[0-9][0-9]([0-9][0-9])? [0-9]' <<<"$date_string" | tail -1 | sed 's/ [0-9]//')")

    # Достаём время из второй даты
    time_str="$(grep -Eo '[0-9][0-9]:[0-9][0-9]$' <<<"$date_string")"

    # Достаём часы из второй даты
    dates_arr+=("$(grep -Eo '^[0-9][0-9]' <<<"$time_str")")

    # Достаём минуты из второй даты
    dates_arr+=("$(grep -Eo '[0-9][0-9]$' <<<"$time_str")")
  fi

  # Дополняем года до 4-значного значения
  if [[ ${#dates_arr[2]} -eq 2 ]]; then
    if [[ ${dates_arr[2]} -le 30 ]]; then
      dates_arr[2]="20""${dates_arr[2]}"
    else
      dates_arr[2]="19""${dates_arr[2]}"
    fi
  fi

  if [[ "$date_type" == "range" ]]; then
    if [[ ${#dates_arr[7]} -eq 2 ]]; then
      if [[ ${dates_arr[7]} -le 30 ]]; then
        dates_arr[7]="20""${dates_arr[5]}"
      else
        dates_arr[7]="19""${dates_arr[5]}"
      fi
    fi
  fi

  echo "${dates_arr[@]}"

  # Проверяем валидность
  local months
  months=(31 28 31 30 31 30 31 31 30 31 30 31)

  # Проверка на високосный год
  if [[ $((dates_arr[2] % 400)) -eq 0 || ($((dates_arr[2] % 100)) -ne 0 && $((dates_arr[2] % 4)) -eq 0) ]]; then
    months[1]=29
  fi

  # Валидируем первую дату
  if [[ ${dates_arr[0]} -gt ${months[$((dates_arr[1] - 1))]} ]]; then
    result=1
  fi

  # Валидируем вторую дату, если первая валидна
  if [[ $result -eq 0 && "$date_type" == "range" ]]; then
    months[1]=28
    if [[ $((dates_arr[7] % 400)) -eq 0 || ($((dates_arr[7] % 100)) -ne 0 && $((dates_arr[7] % 4)) -eq 0) ]]; then
      months[1]=29
    fi

    if [[ ${dates_arr[5]} -gt ${months[$((dates_arr[6] - 1))]} ]]; then
      result=2
    fi
  fi

  return $result
}
