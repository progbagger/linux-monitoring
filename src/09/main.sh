#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

source ./genhtml.sh

# Имя файла метрик
metrics_path="/tmp/metrics.html"

# Зацикливаем создание страницы метрик каждые 5 секунд
if [[ $# -eq 0 ]]; then
  while true; do
    genhtml "$metrics_path"
    sleep 3
  done
else
  echo "No parameters!"
fi
