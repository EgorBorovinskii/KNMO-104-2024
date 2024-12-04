#!/bin/bash

direc="."

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Программа выводит список подкаталогов первого уровня в которых не открыт ни один файл."
            echo "Использование: передайте программе директорию через -d или --directory."
            exit 0
            ;;
        -d|--directory)
            direc="$2"
            shift 2
            ;;
        *)
            echo "Ошибка. Некоректный аргумент."
            exit 1
            ;;
    esac
done

if [[ ! -d "$direc" ]]; then
  echo "Ошибка. Переданная директория не найдена"
  exit 1
fi

subdirs=$(find "$direc" -mindepth 1 -maxdepth 1 -type d)

openFiles=$(lsof +D "$direc" | grep -o '[^ ]*')

flag=0

for dir in $subdirs; do
    if ! echo "$openFiles" | grep -q "^$dir$"; then
        echo "$dir"
        flag=1
    fi
done

if [[ $flag -eq 0 ]]; then
    exit 1
fi

exit 0
