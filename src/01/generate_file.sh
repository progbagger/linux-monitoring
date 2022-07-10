#!/bin/bash

maxsize=$1
maxsize=$((maxsize * 1024))

function genfile() {
  string=""
  for ((i = 0; i < maxsize; i++)); do
    string+="0"
  done

  echo -n "$string"
}
