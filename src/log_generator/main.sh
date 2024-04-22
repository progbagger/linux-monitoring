#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./generate_record.sh

# Создаём цвета
reset="\033[m"
green="\033[92m"
red="\033[91m"
purple="\033[95m"

# Создаем папку для логов
mkdir "nginx_logs"
cd "nginx_logs" || exit 1

# Стартовая дата
start_date="20-07-22"

total_files=0

# Генерируем пять дней
for ((logname = 1; logname <= 5; logname++)); do

  # Выводим сообщение о создании очередного файла логов
  echo -en "$red""Generating file ""$reset""$purple""$logname.log""$reset""$red"" ...""$reset"
  curdate="$start_date"

  # Считаем количество создаваемых записей в логе
  num=$((RANDOM % 901 + 100))

  # Считаем общее количество записей
  total_files=$((total_files + num))

  # Генерируем запись
  for ((i = 0; i < num; i++)); do
    curdate="$(generate_date "$curdate")"
    generate_record "$curdate" >>"$logname.log"
  done

  # Выводим сообщение об окончании генерации файла лога
  echo -e "\b\b\b""$green""Done. Generated ""$reset""$purple""$num""$reset""$green"" records.""$reset"

  # Меняем дату
  start_date="${start_date:0:1}""$((${start_date:1:1} + 1))""${start_date:2}"
done

# Выводим итоговую инфу
echo -e "$green""Script has done its work. Total ""$reset""$purple""$total_files""$reset""$green"" records generated."
