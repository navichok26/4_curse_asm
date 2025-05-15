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
    extern printf, scanf, malloc, calloc, free

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32  ; Выделяем тень для стека (shadow space) + выравнивание
    
    ; Ввод количества элементов
    lea rdi, [prompt_n]
    xor eax, eax
    call printf
    
    lea rdi, [format_int]
    lea rsi, [n]
    xor eax, eax
    call scanf

    ; Выделение памяти для элементов
    mov rdi, [n]
    shl rdi, 3  ; *8 (sizeof(Element))
    call malloc
    mov [elements], rax

    ; Выделение памяти для векторов
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
input_loop:
    mov rax, [i]
    cmp rax, [n]
    jge input_done

    ; Ввод типа элемента
    lea rdi, [prompt_type]
    mov rsi, [i]
    xor eax, eax
    call printf

    lea rdi, [format_int]
    lea rsi, [temp_int]
    xor eax, eax
    call scanf

    ; Сохранение типа в структуре
    mov rax, [elements]
    mov rcx, [i]
    shl rcx, 3
    add rax, rcx
    mov edx, [temp_int]
    mov [rax], edx

    ; Ввод значения в зависимости от типа
    cmp edx, 0
    je input_int
    cmp edx, 1
    je input_float
    cmp edx, 2
    je input_char

input_int:
    lea rdi, [prompt_int]
    xor eax, eax
    call printf

    ; Получаем адрес текущего элемента
    mov rax, [elements]
    mov rcx, [i]
    shl rcx, 3
    add rax, rcx
    
    lea rdi, [format_int]
    lea rsi, [rax+4]  ; value.i
    xor eax, eax
    call scanf
    jmp input_next

input_float:
    lea rdi, [prompt_float]
    xor eax, eax
    call printf

    ; Получаем адрес текущего элемента
    mov rax, [elements]
    mov rcx, [i]
    shl rcx, 3
    add rax, rcx
    
    lea rdi, [format_float]
    lea rsi, [rax+4]  ; value.f
    xor eax, eax
    call scanf
    jmp input_next

input_char:
    lea rdi, [prompt_char]
    xor eax, eax
    call printf

    ; Получаем адрес текущего элемента
    mov rax, [elements]
    mov rcx, [i]
    shl rcx, 3
    add rax, rcx
    
    lea rdi, [format_char]
    lea rsi, [rax+4]  ; value.c
    xor eax, eax
    call scanf

input_next:
    inc qword [i]
    jmp input_loop

input_done:
    ; Создание векторов
    mov qword [i], 0
vector_loop:
    mov rax, [i]
    cmp rax, [n]
    jge vectors_done

    ; Получаем текущий элемент
    mov rax, [elements]
    mov rcx, [i]
    shl rcx, 3
    add rax, rcx

    ; Проверяем тип
    mov edx, [rax]
    cmp edx, 0
    je set_int
    cmp edx, 1
    je set_float
    cmp edx, 2
    je set_char
    jmp next_iter

set_int:
    mov rax, [int_vec]
    add rax, [i]
    mov byte [rax], 1
    jmp next_iter

set_float:
    mov rax, [float_vec]
    add rax, [i]
    mov byte [rax], 1
    jmp next_iter

set_char:
    mov rax, [char_vec]
    add rax, [i]
    mov byte [rax], 1

next_iter:
    inc qword [i]
    jmp vector_loop

vectors_done:
    ; Вывод результатов
    lea rdi, [int_vec_msg]
    xor eax, eax
    call printf

    mov qword [i], 0
print_int_loop:
    mov rax, [i]
    cmp rax, [n]
    jge print_int_done

    mov rax, [int_vec]
    add rax, [i]
    movzx rsi, byte [rax]
    lea rdi, [format_int]
    xor eax, eax
    call printf

    lea rdi, [format_str]
    lea rsi, [space]
    xor eax, eax
    call printf

    inc qword [i]
    jmp print_int_loop

print_int_done:
    lea rdi, [newline]
    xor eax, eax
    call printf

    ; Вывод float вектора
    lea rdi, [float_vec_msg]
    xor eax, eax
    call printf

    mov qword [i], 0
print_float_loop:
    mov rax, [i]
    cmp rax, [n]
    jge print_float_done

    mov rax, [float_vec]
    add rax, [i]
    movzx rsi, byte [rax]
    lea rdi, [format_int]
    xor eax, eax
    call printf

    lea rdi, [format_str]
    lea rsi, [space]
    xor eax, eax
    call printf

    inc qword [i]
    jmp print_float_loop

print_float_done:
    lea rdi, [newline]
    xor eax, eax
    call printf

    ; Вывод char вектора
    lea rdi, [char_vec_msg]
    xor eax, eax
    call printf

    mov qword [i], 0
print_char_loop:
    mov rax, [i]
    cmp rax, [n]
    jge print_char_done

    mov rax, [char_vec]
    add rax, [i]
    movzx rsi, byte [rax]
    lea rdi, [format_int]
    xor eax, eax
    call printf

    lea rdi, [format_str]
    lea rsi, [space]
    xor eax, eax
    call printf

    inc qword [i]
    jmp print_char_loop

print_char_done:
    lea rdi, [newline]
    xor eax, eax
    call printf

    ; Освобождение памяти
    mov rdi, [elements]
    call free
    mov rdi, [int_vec]
    call free
    mov rdi, [float_vec]
    call free
    mov rdi, [char_vec]
    call free

    ; Выход
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret

section .data
space db " ", 0