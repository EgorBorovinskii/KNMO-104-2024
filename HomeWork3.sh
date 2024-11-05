#!/bin/bash

if [[ $1 == "-h" || $1 == "--help" ]]; then
  echo "Скрипт выводит очщенный PATH, в директориях которых хронятся исполняемые файлы"
  echo
  echo "Для того чтобы обработать PATH, запустите программу без параметров."
  echo "Если хотите обработать конкретные пути, то укажите их в качестве аргумента, разделяя их двоеточием."
  echo "Например: /bin:/usr/games:/usr/bin"
  exit 0
fi

directoryInput=()
if [ -n "$1" ]; then
  directoryInput+=("$1")
else
  for dir in $PATH; do
      directoryInput+=("$dir")
  done
fi
IFS=':' read -ra directoryInput <<< "${directoryInput[@]}"

directory=()
for dir in "${directoryInput[@]}"; do
  if [[ -d $dir && ! ${directory[*]} =~ $dir ]]; then
    directory+=("$dir")
  fi
done

answer=()
for dir in "${directory[@]}"; do
  flag=false
  for file in "$dir"/*; do
    if [[ -f "$file" && -x "$file" ]]; then
      flag=true
      break
    fi
  done
  if $flag; then
    answer+=("$dir")
  fi
done

IFS=':'
echo "${answer[*]}"
