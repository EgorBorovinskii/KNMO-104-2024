#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Ошибка: недостаточно аргументов. Используйте -h или --help для справки."
    exit 1
fi

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "Программа принимает в качестве параметра имя конфигурационного файла в следующем формате:"
    echo "time=4s"
    echo "distance=8m"
    echo "longtime=15h"
    echo "weight=42g"
    echo
    echo "Скрипт выводит нормализованный конфиг, все единицы приведены к одному измерению"
    exit 0
fi

if [[ ! -f $1 ]]; then
    echo "Ошибка: файл '$1' не найден."
    exit 1
fi

fileName="$1"

lineNumber=0
while IFS= read -r line; do
    lineNumber=$((lineNumber + 1))
    if [[ $line =~ ^([a-zA-Z]+)=(.*)$ ]]; then
	key=${BASH_REMATCH[1]}
	value=${BASH_REMATCH[2]}

	if echo "$value" | grep -Eq '[0-9]+(h|s|min|d)'; then
    		category="time"
	elif echo "$value" | grep -Eq '[0-9]+(mm|sm|dm|m|km)'; then
    		category="distance"
	elif echo "$value" | grep -Eq '[0-9]+(mg|g|kg|t)'; then
    		category="weight"
	else
    		echo "Ошибка: Некорректные единицы измерения в параметре '$key' на строке $lineNumber."
    		exit 1
	fi

	if echo "$value" | grep -Eq '(h|s|min|d)' && [[ $category != "time" ]]; then
    		echo "Ошибка: Несовместимые единицы времени в параметре '$key' на строке $lineNumber."
    		exit 1
	elif echo "$value" | grep -Eq '(mm|sm|dm|m|km)' && [[ $category != "distance" ]]; then
    		echo "Ошибка: Несовместимые единицы расстояния в параметре '$key' на строке $lineNumber."
    		exit 1
	elif echo "$value" | grep -Eq '(mg|g|kg|t)' && [[ $category != "weight" ]]; then
    		echo "Ошибка: Несовместимые единицы веса в параметре '$key' на строке $lineNumber."
    		exit 1
	fi

	transformedValue=$(echo "$value" | sed -E '
    		s/([0-9]+)s/\1/g;
    		s/([0-9]+)min/\1*60/g;
    		s/([0-9]+)h/\1*3600/g;
    		s/([0-9]+)d/\1*86400/g;

    		s/([0-9]+)mm/\1*0.001/g;
    		s/([0-9]+)sm/\1*0.01/g;
    		s/([0-9]+)dm/\1*0.1/g;
    		s/([0-9]+)m/\1/g;
    		s/([0-9]+)km/\1*1000/g;

    		s/([0-9]+)mg/\1*0.000001/g;
    		s/([0-9]+)g/\1*0.001/g;
    		s/([0-9]+)kg/\1/g;
    		s/([0-9]+)t/\1*1000/g;
	')

	result=$(echo "$transformedValue" | bc -l 2>/dev/null)

	if [[ $? -ne 0 || -z $result ]]; then
    		echo "Ошибка: Некорректное значение параметра '$key' на строке $lineNumber."
	else
    		echo "$key=$result"
	fi
    else
        echo "Ошибка в строке $lineNumber: некорректный синтаксис."
    fi
done < "$fileName"
