#!/bin/bash

# Имя обработчика
jobname="elenenode"

# Сбор информации о потоках ядра
function scrap_cpu_info() {
  # Записываем инфу проца в переменную
  local cpu_info
  cpu_info="$(cat /proc/stat)"

  # Парсим инфу только про ядра процессора
  local cpu_info_arr=()
  while read -r line; do

    # Вытаскиваем первую колонку - названия метрик
    local first_column
    first_column="$(awk '{print $1}' <<<"$line")"

    # Нам подходят только метрики, содержащие "cpu" и любое количество цифр после этого
    if [[ "$first_column" =~ ^cpu[0-9]+$ ]]; then
      cpu_info_arr+=("$line")
    fi
  done <<<"$cpu_info"

  local output_info_arr=()

  # Строим имя PromQL свойства исходя из имени обработчика и того, что он делает
  local metric_name
  metric_name="$jobname""_cpu_seconds_total"

  # Строим нужные нам строчки

  # Информация о свойстве и о его типе
  output_info_arr+=("# HELP $metric_name Total seconds of CPU spent in each mode")
  output_info_arr+=("# TYPE $metric_name counter")

  # Создаём массив имён метрик чтобы вручную не добавлять каждую из них
  local metrics_names_arr
  metrics_names_arr=(
    "user"
    "nice"
    "system"
    "idle"
    "iowait"
    "irq"
    "softirq"
    "steal"
  )

  # Перебираем все потоки, которые удалось вытащить из из /proc/stat
  for thread in "${cpu_info_arr[@]}"; do

    # Достаём номер потока
    local thread_num
    thread_num="$(awk '{print $1}' <<<"$thread" | grep -Eo '[0-9]+')"

    # А теперь весело: парсим столбцы инфы о процессоре и по порядку
    # добавляем в массив строку одной метрики
    local metrics_arr
    metrics_arr=($(awk '{print $2, $3, $4, $5, $6, $7, $8, $9}' <<<"$thread"))
    for ((i = 0; i < ${#metrics_names_arr[@]}; i++)); do
      output_info_arr+=("$metric_name{cpu=\"$thread_num\", mode=\"${metrics_names_arr[$i]}\"} ${metrics_arr[$i]}")
    done
  done

  # Выводим все собранные свойства
  for line in "${output_info_arr[@]}"; do
    echo "$line"
  done
}

# Сбор информации об оперативной памяти в байтах:
# - всего оперативной памяти
# - доступно оперативной памяти
function scrap_mem_info() {
  # Достаём инфу об оперативке
  local mem_info
  mem_info="$(cat /proc/meminfo)"

  # Приводим инфу к нужному нам виду:
  # - убираем столбец с килобайтами
  # - переводим килобайты в байты
  # - убираем двоеточия
  # - меняем все скобки на нижние подчёркивания
  # - добавляем в название каждой метрики "_bytes"
  mem_info="$(awk '{print $1, $2*1024}' <<<"$mem_info" | sed 's/(/_/;s/)//;s/://')"

  # Начинаем формировать свойства

  local metric_name
  metric_name="$jobname""_memory"
  local output_info_arr=()

  # Информация о помощи и типе будут стандартными:
  # "# HELP <jobname>_memory_<metric_name> Information about <metric_name> memory field"
  # "# TYPE gauge"
  # Поэтому будем строить её по ходу постройки свойств

  # Собираем итоговую инфу
  while read -r line; do

    # Достаём имя метрики
    local metric_name
    metric_name="$(awk '{print $1}' <<<"$line")"

    # Достаём значение метрики
    local metric_value
    metric_value="$(awk '{print $2}' <<<"$line")"

    # Добавляем инфу о помощи
    output_info_arr+=("# HELP $jobname""_memory_$metric_name""_bytes Information about $metric_name memory field")

    # Добавляем инфу о типе
    output_info_arr+=("# TYPE $jobname""_memory_$metric_name""_bytes gauge")

    # Добавляем само свойство
    output_info_arr+=("$jobname""_memory_$metric_name""_bytes $metric_value")
  done <<<"$mem_info"

  for line in "${output_info_arr[@]}"; do
    echo "$line"
  done
}

# Сбор инфы о файловой системе:
# - total - всего байт
# - free - свободно байт
# - used - использовано байт
function scrap_filesystem_info() {
  # Записываем инфу о диске
  local space_info
  space_info="$(df -B1 -t ext4 | tail -2 | awk '{print $1, $2, $3, $4}')"

  # Создаём массив имён свойств
  local props_names_arr
  props_names_arr=(
    "total"
    "used"
    "avail"
  )

  # Строим сами свойства
  local output_info_arr=()

  # Счётчик пройдённых свойств
  local prop_count=0
  for prop_name in "${props_names_arr[@]}"; do
    prop_count=$((prop_count + 1))
    # Строим имя свойства
    local metric_name
    metric_name="$jobname""_filesystem_$prop_name""_bytes"

    # Добавляем строку помощи
    output_info_arr+=("# HELP $metric_name Information about $prop_name bytes in filesystem")

    # Добавляем строку типа
    output_info_arr+=("# TYPE $metric_name gauge")
    while read -r line; do

      # Добавляем свойство на каждый найденный том
      local disk
      disk="$(awk '{print $1}' <<<"$line")"

      # Строим строку свойства
      local metric_str
      metric_str="$metric_name"

      # В зависимости от свойства добавляем тот или иной столбец инфы
      local line_arr
      line_arr=($line)
      metric_str+="{device=\"$disk\"}"
      metric_str+=" ${line_arr[$((prop_count))]}"

      output_info_arr+=("$metric_str")
    done <<<"$space_info"
  done

  for metric in "${output_info_arr[@]}"; do
    echo "$metric"
  done
}

# Функция для получения всей нужной инфы о системе
function scrap() {
  local metrics_arr=()

  # Получаем инфу о процессоре
  local cpu_info
  cpu_info="$(scrap_cpu_info)"

  while read -r line; do
    metrics_arr+=("$line")
  done <<<"$cpu_info"

  # Получаем инфу о памяти
  local mem_info
  mem_info="$(scrap_mem_info)"

  while read -r line; do
    metrics_arr+=("$line")
  done <<<"$mem_info"

  # Получаем инфу о диске
  local disk_info
  disk_info="$(scrap_filesystem_info)"

  while read -r line; do
    metrics_arr+=("$line")
  done <<<"$disk_info"

  for line in "${metrics_arr[@]}"; do
    echo "$line"
  done
}
