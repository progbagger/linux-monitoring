#!/bin/bash

# $1 - имя файла
# $2 - размер файла
# $3 - модификатор размера файла
function genfile() {
  local name
  name="$1"

  local size
  size=$2

  local power
  power="$3"

  # Непосредственно создание файла указанного имени и размера
  fallocate -l "$size""$power" "$name"
}
