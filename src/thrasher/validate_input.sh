#!/bin/bash

# $1 - директория, в которой мусорить
# $2 - количество поддиректорий
# $3 - символы имён поддиректорий
# $4 - количество файлов в каждой поддиректории
# $5 - имена и расширения файлов
# $6 - размер в килобайтах
# $7 - количество аргументов, переданных в main.sh
validate_input() {
  local result
  result=0

  # Валидация количества параметров
  if [[ $7 -ne 6 ]]; then
    echo "This script must be executed with exactly 6 parameters."
    result=1
  else

    # Валидация первого параметра:
    # - папка не должна существовать
    if [[ -d "$1" ]]; then
      echo "- 1-st param: This folder is already exist."
      result=1
    fi

    # Валидация второго параметра:
    # - параметр должен быть числом
    # - параметр должен быть положительным
    if ! [[ "$2" =~ [[:digit:]] && $2 -ge 0 ]]; then
      echo "- 2-nd param: Must be digit greater than 0."
      result=1
    fi

    # Валидация третьего параметра
    # - параметр должен быть строкой
    # - параметр должен иметь длину больше нуля
    # - параметр должен иметь длину меньше семи
    if ! [[ "$3" =~ [[:alpha:]] && ${#3} -le 7 && ${#3} -gt 0 ]]; then
      echo "- 3-rd param: Must consist of English alphabet and have length of 7 characters."
      result=1
    fi

    # Валидация четвёртого параметра
    # - параметр должен быть числом
    # - параметр должен быть положительным
    if ! [[ "$4" =~ [[:digit:]] && $4 -gt 0 ]]; then
      echo "- 4-th param: Must be digit greater than 0."
      result=1
    fi

    # Парсинг имени файла на непосредственно имя и его расширение
    local name
    name="$(grep -oE '^.*\.' <<<"$5" | sed 's/\.//')"

    local extension
    extension="$(grep -oE '\..*$' <<<"$5" | sed 's/\.//')"

    # Валидация пятого параметра:
    # - имя должно быть строкой с длиной от 1 до 7 включая
    # - расширение должно быть строкой с длиной от 1 до 3 включая
    if ! [[ "$name" =~ [[:alpha:]] && ${#name} -le 7 && "$extension" =~ [[:alpha:]] && ${#extension} -le 3 ]]; then
      echo "- 5-th param: Must be in format \"abcdefg.abc\"."
      result=1
    fi

    # Уничтожение буквы размера файла
    local value
    value="$(grep -oE '^[[:digit:]].*(kb)' <<<"$6" | sed 's/kb//')"

    # Валидация шестого параметра:
    # - параметр должен быть числом от 1 до 100 включая
    if ! [[ $value -gt 0 && $value -le 100 ]]; then
      echo "- 6-th param: Must be in format nkb, 0 < n <= 100."
      result=1
    fi
  fi
  if [[ $result -eq 1 ]]; then
    echo "Please, try again."
  fi
  return $result
}
