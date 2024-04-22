#!/bin/bash
# Отключаем проверку подключаемых файлов
# shellcheck disable=SC1091

relative_path="$(dirname "$0")"

source "$relative_path"/thrasher/change_file_name.sh
source "$relative_path"/thrasher/generate_file.sh
source "$relative_path"/thrasher/logger.sh
source "$relative_path"/thrasher/output_info.sh

# $1 - символы имён поддиректорий
# $2 - символы имён файлов
# $3 - размер в мегабайтах
function party_hard() {
  # Файл логов
  local logfile
  logfile="$(pwd)/created_files.log"

  # Текущая дата
  local date
  date="$(date '+%d%m%y')"

  local available_folders_names
  available_folders_names="$1"

  # Доступные символы имени файлов
  local available_files_names
  available_files_names="$(grep -Eo '.*\.' <<<"$2" | sed 's/\.//')"

  # Доступные символы расширений
  local extension
  extension="$(grep -Eo '\..*' <<<"$2" | sed 's/\.//')"

  local size
  size="$(sed 's/Mb//' <<<"$3")"

  # Список путей, куда можно создавать файлы
  local folders_list

  # Список количества созданных файлов в данной директории
  local folders_count

  # Список проверок, создана ли данная папка нами
  local created_folders

  # Поиск путей, доступных для записи
  local paths

  # Ищем все директории, в которые можно создать папку, в домашней директории пользователя
  paths="$(find "$HOME" -type d -writable 2>/dev/null)"
  for path in $paths; do
    folders_list+=("$path")
    folders_count+=(0)
    created_folders+=(0)
  done

  paths="$(find /tmp -type d -writable 2>/dev/null)"
  for path in $paths; do
    folders_list+=("$path")
    folders_count+=(0)
    created_folders+=(0)
  done

  # Создаём переменные для имён
  local current_folder
  local current_filename

  current_filename=""
  current_folder=""

  # Сканируем свободное место
  avail_space="$(df -BM "$(pwd)" | tail -1 | awk '{print $4}' | sed 's/M//')"

  # Выводим свободное место перед началом соренья
  output_space_at_start "$avail_space"

  # Начинаем генерацию
  local files_total=0
  local folders_total=0
  local errors_count=0
  while [[ $avail_space -ge 1024 ]]; do
    # Выбираем случайный путь из списка
    local num
    num=$((RANDOM % ${#folders_list}))
    cd "${folders_list[$num]}" || exit 1

    # Меняем имя папки и создаём её, если в подпапке не создано слишком много подпапок
    local is_folder_created=0
    if [[ ${folders_count[$num]} -lt 100 && ${created_folders[$num]} -ne 1 ]]; then
      change_file_name current_folder "$available_folders_names" "5"
      mkdir "$current_folder""_""$date" 2>/dev/null
      check=$?

      # Проверяем, удалось ли создать директорию
      if [[ $check -eq 0 ]]; then

        # Если удалось, то меняем папку и создаём там файлы
        errors_count=0
        folders_total=$((folders_total + 1))
        record "$current_folder""_""$date" "$logfile" "folder"
        is_folder_created=1
        folders_list+=("$(pwd)/""$current_folder""_""$date")
        folders_count+=(0)
        created_folders+=(1)
        folders_count[$num]=$((${folders_count[$num]} + 1))
        cd "$current_folder""_""$date" || exit 1
      else

        # Если слишком много ошибок подряд - сбрасываем имена файлов и папок
        if [[ $errors_count -ge 20 ]]; then
          current_filename=""
          current_folder=""
          errors_count=0
        else
          errors_count=$((errors_count + 1))
        fi
      fi
    elif [[ ${created_folders[$num]} -eq 1 ]]; then
      cd "${folders_list[$num]}" || exit 1
    fi

    # Создаём файлик, если места хватает
    current_filename=""
    local files_to_create_count

    # Выбираем количество файлов, которые будем создавать в папке
    files_to_create_count=$((RANDOM % 30 + 1))

    local created_files_count=0
    while [[ $avail_space -ge 1024 && $created_files_count -lt $files_to_create_count && $is_folder_created -eq 1 ]]; do
      created_files_count=$((created_files_count + 1))

      # Меняем имя файла
      change_file_name current_filename "$available_files_names" "5"

      # Генерируем файлик с указанными именем и размером
      genfile "$current_filename""_""$date"".""$extension" "$size" "M"
      files_total=$((files_total + 1))

      # Логируем файлик
      record "$current_filename""_""$date"".""$extension" "$logfile" "file"

      # Выводим текущее свободное место
      avail_space="$(df -BM "$(pwd)" | tail -1 | awk '{print $4}' | sed 's/M//')"
      output_current_space "$avail_space"
    done
  done

  # Выводим итоги
  output_results "$folders_total" "$files_total"
}
