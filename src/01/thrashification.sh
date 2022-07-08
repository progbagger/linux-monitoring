#!/bin/bash

function party_hard() {
  subfolders_total=$1
  folders_names_letters="$2"
  files_total=$3
  files_names_letters="$4"
  file_size=$(grep -oE '^[[:digit:]].*(kb)' <<<"$6" | sed 's/kb//')
  while [[ $(df -BM / | tail -n -1 | awk '{print $4}' | sed 's/M//') >= 1024 ]]; do
    
  done
}
