#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Программа ищет 99 перцентиль по времени обработки запросов."
  echo "Далее записывает в новый файл только те логи, у которых время обработки меньше чем найденный перцентиль."
  echo "Запись логов идет в формате сортировки по времени и по названию ресурса."
  echo
  echo "Чтобы запустить программу, передайте ей файл с логами."
  exit 0
fi

if [ -z "$1" ]; then
  echo "Передайте программе файл с логами или -h или --help."
  exit 1
fi

inputFile=$1
outputFile="answer.txt"

if [ ! -f "$inputFile" ]; then
  echo "Ошибка. Переданного вами файла не существует."
  exit 1
fi

execTimes=$(awk -F'|' '{print $5}' "$inputFile" | tr -d ' ' | sort -n)
totalCount=$(echo "$execTimes" | wc -l)
index=$((totalCount * 99 / 100))
percentil=$(echo "$execTimes" | sed -n "${index}p")

awk -F'|' -v p="$percentil" '
{
  execTime = $5 + 0;
  if (execTime < p)
  {
   printf "%-6s| %s | %-15s | %s | %s\n", $1, $2, $3, $4, execTime;
  }
}' "$inputFile" | sort -t'|' -k5,5n -k4,4 > "$outputFile"
echo "Файл готов."
