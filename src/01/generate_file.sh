#!/bin/bash

function genfile() {
  # Имя файла
  local name
  name="$1"

  # Размер файла
  local size
  size=$2

  # Постфикс размера: мегабайты или килобайты
  local power
  power="$3"

  # Непосредственно создание файла указанного имени и размера
  fallocate -l "$size""$power" "$name"
}
