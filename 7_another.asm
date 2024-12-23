; filepath: /home/x5113nc3x/repos/4_curse_asm/7_another.asm
section .data
    prompt      db "Enter a 4-byte unsigned integer: ", 0
    format_in   db "%u", 0
    format_out  db "Reversed bits: %u", 10, 0

section .bss
    number      resd 1         ; Буфер для хранения входного числа
    reversed    resd 1         ; Буфер для хранения перевёрнутого числа

section .text
    extern printf, scanf
    global main

main:
    ; Установка фрейма стека
    push rbp
    mov rbp, rsp
    sub rsp, 16                  ; Выделение 16 байт на стеке для выравнивания

    ; Вывод приглашения
    lea rdi, [rel prompt]
    xor eax, eax                 ; Очистка RAX для вариативных функций
    call printf

    ; Чтение входного числа
    lea rsi, [rel number]
    lea rdi, [rel format_in]
    xor eax, eax                 ; Очистка RAX для вариативных функций
    call scanf

    ; Загрузка числа в EAX
    mov eax, [number]
    xor ebx, ebx                  ; Инициализация перевёрнутого числа нулём
    mov ecx, 32                   ; Установка счетчика битов на 32

reverse_loop:
    shl ebx, 1                    ; Сдвиг перевёрнутого числа влево на 1 бит
    shr eax, 1                    ; Сдвиг исходного числа вправо на 1 бит, CF = извлечённый бит
    jnc skip_set                  ; Если бит не установлен, пропускаем
    or ebx, 1                     ; Устанавливаем последний бит перевёрнутого числа
skip_set:
    dec ecx                       ; Уменьшаем счётчик битов
    jnz reverse_loop              ; Повторяем до обработки всех 32 битов

    mov [reversed], ebx           ; Сохранение перевёрнутого числа

    ; Вывод перевёрнутого числа
    mov esi, ebx                  ; Второй аргумент для printf (%u)
    lea rdi, [rel format_out]      ; Первый аргумент для printf (форматная строка)
    xor eax, eax                  ; Очистка RAX для вариативных функций
    call printf

    ; Очистка и выход
    mov eax, 0                    ; Установка кода возврата 0
    leave
    ret