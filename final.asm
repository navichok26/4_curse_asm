section .data
    prompt_n       db "Enter number of elements: ", 0
    prompt_type    db "Element %d: enter type (0 - int, 1 - float, 2 - char): ", 0
    prompt_int     db "Enter integer: ", 0
    prompt_float   db "Enter float: ", 0
    prompt_char    db "Enter char: ", 0
    int_vec_msg    db "Int vector:    ", 0
    float_vec_msg  db "Float vector:  ", 0
    char_vec_msg   db "Char vector:   ", 0
    newline        db 10, 0
    format_int     db "%d", 0
    format_float   db "%f", 0
    format_char    db " %c", 0
    format_str     db "%s", 0

section .bss
    n           resd 1
    elements    resq 1
    int_vec     resq 1
    float_vec   resq 1
    char_vec    resq 1
    i           resd 1
    temp_int    resd 1
    temp_float  resd 1
    temp_char   resb 1

section .text
    global main
    extern printf, scanf, malloc, calloc, free

main:
    ; Выделяем память и вводим данные
    call input_data

    ; Формируем булевы вектора
    call create_vectors

    ; Выводим результаты
    call print_results

    ; Освобождаем память
    call free_memory

    ; Выход
    mov eax, 0
    ret

input_data:
    ; Запрос количества элементов
    push prompt_n
    call printf
    add esp, 4

    ; Ввод n
    push n
    push format_int
    call scanf
    add esp, 8

    ; Выделяем память для элементов
    mov eax, [n]
    imul eax, 8          ; sizeof(Element) = 8 (enum + union)
    push eax
    call malloc
    add esp, 4
    mov [elements], eax

    ; Выделяем память для векторов
    mov eax, [n]
    push eax
    push 1
    call calloc
    add esp, 8
    mov [int_vec], eax

    mov eax, [n]
    push eax
    push 1
    call calloc
    add esp, 8
    mov [float_vec], eax

    mov eax, [n]
    push eax
    push 1
    call calloc
    add esp, 8
    mov [char_vec], eax

    ; Ввод элементов
    mov dword [i], 0
.input_loop:
    mov eax, [i]
    cmp eax, [n]
    jge .input_end

    ; Вывод приглашения для типа
    push eax
    push prompt_type
    call printf
    add esp, 8

    ; Ввод типа
    lea eax, [temp_int]
    push eax
    push format_int
    call scanf
    add esp, 8

    ; Сохраняем тип в структуре
    mov ecx, [elements]
    mov edx, [i]
    imul edx, 8
    add ecx, edx
    mov eax, [temp_int]
    mov [ecx], eax

    ; Ввод значения в зависимости от типа
    cmp eax, 0
    je .input_int
    cmp eax, 1
    je .input_float
    cmp eax, 2
    je .input_char

.input_int:
    push prompt_int
    call printf
    add esp, 4

    lea eax, [ecx+4]  ; поле value.i
    push eax
    push format_int
    call scanf
    add esp, 8
    jmp .input_next

.input_float:
    push prompt_float
    call printf
    add esp, 4

    lea eax, [ecx+4]  ; поле value.f
    push eax
    push format_float
    call scanf
    add esp, 8
    jmp .input_next

.input_char:
    push prompt_char
    call printf
    add esp, 4

    lea eax, [ecx+4]  ; поле value.c
    push eax
    push format_char
    call scanf
    add esp, 8

.input_next:
    inc dword [i]
    jmp .input_loop

.input_end:
    ret

create_vectors:
    mov dword [i], 0
.vector_loop:
    mov eax, [i]
    cmp eax, [n]
    jge .vector_end

    ; Получаем текущий элемент
    mov ecx, [elements]
    mov edx, eax
    imul edx, 8
    add ecx, edx

    ; Проверяем тип
    mov edx, [ecx]
    cmp edx, 0
    je .set_int
    cmp edx, 1
    je .set_float
    cmp edx, 2
    je .set_char
    jmp .next_iter

.set_int:
    mov ecx, [int_vec]
    add ecx, [i]
    mov byte [ecx], 1
    jmp .next_iter

.set_float:
    mov ecx, [float_vec]
    add ecx, [i]
    mov byte [ecx], 1
    jmp .next_iter

.set_char:
    mov ecx, [char_vec]
    add ecx, [i]
    mov byte [ecx], 1

.next_iter:
    inc dword [i]
    jmp .vector_loop

.vector_end:
    ret

print_results:
    ; Вывод вектора целых чисел
    push int_vec_msg
    call printf
    add esp, 4

    mov dword [i], 0
.print_int_loop:
    mov eax, [i]
    cmp eax, [n]
    jge .print_int_end

    mov ecx, [int_vec]
    add ecx, eax
    movzx eax, byte [ecx]
    push eax
    push format_int
    call printf
    add esp, 8

    push ' '
    call putchar
    add esp, 4

    inc dword [i]
    jmp .print_int_loop

.print_int_end:
    push newline
    call printf
    add esp, 4

    ; Вывод вектора вещественных чисел
    push float_vec_msg
    call printf
    add esp, 4

    mov dword [i], 0
.print_float_loop:
    mov eax, [i]
    cmp eax, [n]
    jge .print_float_end

    mov ecx, [float_vec]
    add ecx, eax
    movzx eax, byte [ecx]
    push eax
    push format_int
    call printf
    add esp, 8

    push ' '
    call putchar
    add esp, 4

    inc dword [i]
    jmp .print_float_loop

.print_float_end:
    push newline
    call printf
    add esp, 4

    ; Вывод вектора символов
    push char_vec_msg
    call printf
    add esp, 4

    mov dword [i], 0
.print_char_loop:
    mov eax, [i]
    cmp eax, [n]
    jge .print_char_end

    mov ecx, [char_vec]
    add ecx, eax
    movzx eax, byte [ecx]
    push eax
    push format_int
    call printf
    add esp, 8

    push ' '
    call putchar
    add esp, 4

    inc dword [i]
    jmp .print_char_loop

.print_char_end:
    push newline
    call printf
    add esp, 4
    ret

free_memory:
    push dword [elements]
    call free
    add esp, 4

    push dword [int_vec]
    call free
    add esp, 4

    push dword [float_vec]
    call free
    add esp, 4

    push dword [char_vec]
    call free
    add esp, 4
    ret