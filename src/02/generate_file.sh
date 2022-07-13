#!/bin/bash

function genfile() {
  local name
  name="$1"

  local size
  size=$2

  fallocate -l "$size"M "$name"
}
