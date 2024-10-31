#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Использование: N, M, Директория, Результат"
    echo 
    echo "Параметры:"
    echo "N-Число изображений по горизонтали"
    echo "M-Число изображений по вертикали"
    echo "Директория-Путь к папке с изображениями"
    echo "Результат-Имя выходного файла в формате jpg"
    exit 0
fi

if [ "$#" != 4 ]; then
    echo "Ошибка: недостаточно параметров"
    exit 1
fi

N=$1
M=$2
inputDirectory=$3
outputFile=$4

if ! [[ "$N" =~ ^[0-9]+$ ]] || ! [[ "$M" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: N и M должны быть положительными целыми числами"
    exit 1
fi

if ! [ -d "$inputDirectory" ]; then
    echo "Ошибка: переданная директория не существует"
    exit 1
fi

images=($(ls "$inputDirectory"/* 2>/dev/null | sort))

if [ "${#images[@]}" == 0 ]; then
    echo "Ошибка: в директории нет файлов"
    exit 1
fi

realImages=()
for img in "${images[@]}"; do
    mimetype=$(file --mime-type -b "$img")
    if [[ "$mimetype" == image/* ]]; then
        realImages+=("$img")
    else
        echo "Внимание: файл $img не является изображением"
    fi
done

needNumberOfImages=$((N * M))

if [ "${#realImages[@]}" -lt "$needNumberOfImages" ]; then
    echo "Ошибка: недостаточно изображений. Требуется $needNumberOfImages"
    exit 1
fi

realImages=("${realImages[@]:0:$needNumberOfImages}")

firstImage="${realImages[0]}"
size=$(identify -format "%wx%h" "$firstImage")
width=$(echo $size | cut -d'x' -f1)
height=$(echo $size | cut -d'x' -f2)

for img in "${realImages[@]}"; do
    mogrify -resize "${width}x${height}" "$img"
done

montage "${realImages[@]}" -tile "${N}x${M}" -geometry "${width}x${height}" "$outputFile"

echo "Коллаж успешно создан: $outputFile"
