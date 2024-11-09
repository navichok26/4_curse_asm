#!/bin/bash

# Проверка количества аргументов
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 path/to/file.asm path/to/output"
    exit 1
fi

ASM_FILE="$1"
OUTPUT_FILE="$2"
OBJ_FILE="${OUTPUT_FILE}.o"

# Компиляция с nasm
nasm -f elf64 "$ASM_FILE" -o "$OBJ_FILE"
if [ $? -ne 0 ]; then
    echo "Ошибка при компиляции .asm файла"
    exit 1
fi

# Линковка с ld и libc
ld "$OBJ_FILE" -o "$OUTPUT_FILE" -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2
if [ $? -ne 0 ]; then
    echo "Ошибка при линковке"
    exit 1
fi

# Удаление объектного файла
rm "$OBJ_FILE"

echo "Компиляция завершена: $OUTPUT_FILE"