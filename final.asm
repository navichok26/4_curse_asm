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
    space          db " ", 0

section .bss
    n           resq 1
    elements    resq 1
    int_vec     resq 1
    float_vec   resq 1
    char_vec    resq 1
    i           resq 1
    temp_int    resd 1
    temp_float  resd 1
    temp_char   resb 1

section .text
    global main
    extern printf, scanf, malloc, calloc, free, putchar

main:
    push rbp
    mov rbp, rsp
    
    ; Выделяем память и вводим данные
    call input_data

    ; Формируем булевы вектора
    call create_vectors

    ; Выводим результаты
    call print_results

    ; Освобождаем память
    call free_memory

    ; Выход
    mov rax, 0
    pop rbp
    ret

input_data:
    ; Запрос количества элементов
    mov rdi, prompt_n
    xor rax, rax
    call printf

    ; Ввод n
    mov rdi, format_int
    mov rsi, n
    xor rax, rax
    call scanf

    ; Выделяем память для элементов (8 байт на элемент)
    mov rdi, [n]
    imul rdi, 8          ; sizeof(Element) = 8 (enum + union)
    call malloc
    mov [elements], rax

    ; Выделяем память для векторов
    mov rdi, [n]
    mov rsi, 1
    call calloc
    mov [int_vec], rax

    mov rdi, [n]
    mov rsi, 1
    call calloc
    mov [float_vec], rax

    mov rdi, [n]
    mov rsi, 1
    call calloc
    mov [char_vec], rax

    ; Ввод элементов
    mov qword [i], 0
.input_loop:
    mov rax, [i]
    cmp rax, [n]
    jge .input_end

    ; Вывод приглашения для типа
    mov rdi, prompt_type
    mov rsi, [i]
    xor rax, rax
    call printf

    ; Ввод типа
    mov rdi, format_int
    mov rsi, temp_int
    xor rax, rax
    call scanf

    ; Сохраняем тип в структуре
    mov rcx, [elements]
    mov rdx, [i]
    imul rdx, 8
    add rcx, rdx
    mov eax, [temp_int]
    mov [rcx], eax

    ; Ввод значения в зависимости от типа
    cmp eax, 0
    je .input_int
    cmp eax, 1
    je .input_float
    cmp eax, 2
    je .input_char

.input_int:
    mov rdi, prompt_int
    xor rax, rax
    call printf

    lea rsi, [rcx+4]  ; поле value.i
    mov rdi, format_int
    xor rax, rax
    call scanf
    jmp .input_next

.input_float:
    mov rdi, prompt_float
    xor rax, rax
    call printf

    lea rsi, [rcx+4]  ; поле value.f
    mov rdi, format_float
    xor rax, rax
    call scanf
    jmp .input_next

.input_char:
    mov rdi, prompt_char
    xor rax, rax
    call printf

    lea rsi, [rcx+4]  ; поле value.c
    mov rdi, format_char
    xor rax, rax
    call scanf

.input_next:
    inc qword [i]
    jmp .input_loop

.input_end:
    ret

create_vectors:
    mov qword [i], 0
.vector_loop:
    mov rax, [i]
    cmp rax, [n]
    jge .vector_end

    ; Получаем текущий элемент
    mov rcx, [elements]
    mov rdx, [i]
    imul rdx, 8
    add rcx, rdx

    ; Проверяем тип
    mov edx, [rcx]
    cmp edx, 0
    je .set_int
    cmp edx, 1
    je .set_float
    cmp edx, 2
    je .set_char
    jmp .next_iter

.set_int:
    mov rcx, [int_vec]
    add rcx, [i]
    mov byte [rcx], 1
    jmp .next_iter

.set_float:
    mov rcx, [float_vec]
    add rcx, [i]
    mov byte [rcx], 1
    jmp .next_iter

.set_char:
    mov rcx, [char_vec]
    add rcx, [i]
    mov byte [rcx], 1

.next_iter:
    inc qword [i]
    jmp .vector_loop

.vector_end:
    ret

print_results:
    ; Вывод вектора целых чисел
    mov rdi, int_vec_msg
    xor rax, rax
    call printf

    mov qword [i], 0
.print_int_loop:
    mov rax, [i]
    cmp rax, [n]
    jge .print_int_end

    mov rcx, [int_vec]
    add rcx, [i]
    movzx rdi, byte [rcx]
    mov rsi, format_int
    xor rax, rax
    call printf

    mov rdi, space
    xor rax, rax
    call printf

    inc qword [i]
    jmp .print_int_loop

.print_int_end:
    mov rdi, newline
    xor rax, rax
    call printf

    ; Вывод вектора вещественных чисел
    mov rdi, float_vec_msg
    xor rax, rax
    call printf

    mov qword [i], 0
.print_float_loop:
    mov rax, [i]
    cmp rax, [n]
    jge .print_float_end

    mov rcx, [float_vec]
    add rcx, [i]
    movzx rdi, byte [rcx]
    mov rsi, format_int
    xor rax, rax
    call printf

    mov rdi, space
    xor rax, rax
    call printf

    inc qword [i]
    jmp .print_float_loop

.print_float_end:
    mov rdi, newline
    xor rax, rax
    call printf

    ; Вывод вектора символов
    mov rdi, char_vec_msg
    xor rax, rax
    call printf

    mov qword [i], 0
.print_char_loop:
    mov rax, [i]
    cmp rax, [n]
    jge .print_char_end

    mov rcx, [char_vec]
    add rcx, [i]
    movzx rdi, byte [rcx]
    mov rsi, format_int
    xor rax, rax
    call printf

    mov rdi, space
    xor rax, rax
    call printf

    inc qword [i]
    jmp .print_char_loop

.print_char_end:
    mov rdi, newline
    xor rax, rax
    call printf
    ret

free_memory:
    mov rdi, [elements]
    call free

    mov rdi, [int_vec]
    call free

    mov rdi, [float_vec]
    call free

    mov rdi, [char_vec]
    call free
    ret