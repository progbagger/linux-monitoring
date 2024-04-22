#!/bin/bash

function generate_ip() {
  local ip=""

  # Построение адреса
  for ((i = 0; i < 4; i++)); do
    ip+=$((RANDOM % 256))

    # В адресе не должно быть точки после последнего числа
    if [[ $i -ne $((4 - 1)) ]]; then
      ip+="."
    fi
  done

  echo "$ip"
}

function generate_response() {
  # Создаём список допустимых кодов ответа
  local response_list
  response_list=(
    200 # OK - запрос успешно обработан
    201 # Created - ответ на PUT - ресурс создан
    400 # Bad Request - неверный синтаксис запроса
    401 # Unauthorized - для выполнения запроса требуется авторизация
    403 # Forbidden - недостаточно прав для выполнения запроса
    404 # Not Found - ресурс не найден
    500 # Internal Server Error - сервер не обработал ситуацию
    501 # Not Implemented - запрос не может быть обработан сервером
    502 # Bad Gateway - получен недействительный ответ
    503 # Service Unavailable - сервер не готов обработать запрос
  )

  # Выбираем случайный код из списка
  local num
  num=$((RANDOM % ${#response_list[@]}))

  echo "${response_list[$num]}"
}

function generate_method() {
  # Создаём список допустимых методов
  local methods_list
  methods_list=("GET" "POST" "PUT" "PATCH" "DELETE")

  # Выбираем случайный метод из списка
  local num
  num=$((RANDOM % ${#methods_list[@]}))

  echo "${methods_list[$num]}"
}

function generate_agent() {
  # Создаём список допустимых агентов
  local agents_list
  agents_list=("Mozilla" "Google Chrome" "Opera" "Safari" "Internet Explorer" "Microsoft Edge" "Crawler and bot" "Library and net tool")

  # Выбираем случайный агент из списка
  local num
  num=$((RANDOM % ${#agents_list[@]}))

  echo "${agents_list[$num]}"
}

function generate_url() {
  # Создаём список URL-ов
  local url_list
  url_list=(
    "https://google.ru"
    "https://yandex.ru"
    "https://edu.21-school.ru"
    "https://youtube.com"
    "https://vk.com"
    "https://stepik.org"
    "https://habr.com"
    "https://vc.ru"
  )

  # Выбираем случайный URL из списка
  local num
  num=$((RANDOM % ${#url_list[@]}))

  echo "${url_list[$num]}"
}

# $1 - предыдущая дата/время; если задана только дата - создать время с нуля,
#      иначе - увеличить время
function generate_date() {
  local date
  date="$1"

  if [[ "$date" =~ ^[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$ ]]; then
    date="$date:00:00:00"
  else

    # Парсим день-месяц-год
    local ymd
    ymd="$(grep -Eo '^.*-[0-9][0-9]' <<<"$date")"

    # Парсим час-минуты-секунды
    local hms
    hms="$(grep -Eo ':.*$' <<<"$date" | sed 's/://')"

    # Вытаскиваем часы
    local hours
    hours="$(grep -Eo '^[0-9][0-9]' <<<"$hms")"
    if [[ "${hours:0:1}" == "0" && "${hours:1:1}" != "0" ]]; then
      hours="${hours: -1}"
    fi

    # Вытаскимаем минуты
    local minutes
    minutes="$(grep -Eo ':[0-9][0-9]:' <<<"$hms" | sed 's/://; s/://')"
    if [[ "${minutes:0:1}" == "0" && "${minutes:1:1}" != "0" ]]; then
      minutes="${minutes: -1}"
    fi

    # Выбираем случайные секунды
    local seconds
    seconds=$((RANDOM % 60))

    # Увеличиваем минуты на 1
    minutes=$((minutes + 1))

    # Если минут больше 59, то сбросить их на 0 и увеличить часы
    if [[ $minutes -ge 60 ]]; then
      minutes=0
      ((hours++))
    fi

    # Формируем итоговую дату
    date="$ymd:"
    if [[ ${#hours} -eq 1 ]]; then
      date+="0"
    fi
    date+="$hours:"

    if [[ ${#minutes} -eq 1 ]]; then
      date+="0"
    fi
    date+="$minutes:"

    if [[ ${#seconds} -eq 1 ]]; then
      date+="0"
    fi
    date+="$seconds"
  fi

  echo "$date"
}

# $1 - текущая дата (+ время). Если без времени - собирается дата по умолчанию: <дата> 00:00:00
function generate_record() {
  local current_date
  current_date="$1"

  local record=""

  # Добавляем IP
  record+="$(generate_ip) "

  # Добавляем дату
  record+="[$(generate_date "$current_date")] "

  # Добавляем метод
  record+="\"$(generate_method)\" "

  # Добавляем код ответа
  record+="$(generate_response) "

  # Добавляем URL
  record+="\"$(generate_url)\" "

  # Добавляем агент
  record+="\"$(generate_agent)\""

  echo "$record"
}
