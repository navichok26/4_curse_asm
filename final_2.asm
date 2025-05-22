section .data
    matrix dq 1.2, -2.3, 3.4, 4.5, -5.6
           dq 2.1, 3.2, -4.3, 5.4, 6.5
           dq -1.1, 2.2, 3.3, -4.4, 5.5
           dq 6.6, -7.7, 8.8, 9.9, -10.1
           dq 1.0, 2.0, 3.0, 4.0, 5.0

    fmt_sum db "Sum of row %d: %d", 10, 0
    fmt_min db "Min sum: %d", 10, 0
    fmt_max db "Max sum: %d", 10, 0

section .bss
    row_sums resq 5

section .text
    extern printf
    global main

main:
    push rbp
    mov rbp, rsp
    and rsp, -16    ; Выравнивание стека по 16 байтам
    sub rsp, 16     ; Выделяем выровненное пространство для локальных переменных

    mov rcx, 0
rowsum_loop:
    cmp rcx, 5
    jge rowsum_done

    mov rbx, rcx
    imul rbx, 5
    mov rsi, rbx
    imul rsi, 8
    lea rdi, [matrix + rsi]

    fld qword [rdi]
    fld qword [rdi+8]
    faddp st1, st0
    fld qword [rdi+16]
    faddp st1, st0
    fld qword [rdi+24]
    faddp st1, st0
    fld qword [rdi+32]
    faddp st1, st0

    fstp qword [row_sums + rcx*8]

    inc rcx
    jmp rowsum_loop
rowsum_done:

    ; min/max
    mov rcx, 0
    fld qword [row_sums]
    fstp qword [row_sums+40]    ; min
    fld qword [row_sums]
    fstp qword [row_sums+48]    ; max

find_minmax_loop:
    inc rcx
    cmp rcx, 5
    jge find_minmax_done

    fld qword [row_sums + rcx*8]
    fld qword [row_sums+48]     ; max
    fcomi st0, st1
    jae .skip_max
    fstp qword [row_sums+48]
    fstp st0
    jmp .after_max
.skip_max:
    fstp st0
    fstp st0
.after_max:

    fld qword [row_sums + rcx*8]
    fld qword [row_sums+40]     ; min
    fcomi st0, st1
    jbe .skip_min
    fstp qword [row_sums+40]
    fstp st0
    jmp .after_min
.skip_min:
    fstp st0
    fstp st0
.after_min:

    jmp find_minmax_loop
find_minmax_done:

    ; print sums
    mov rcx, 0
print_sums_loop:
    cmp rcx, 5
    jge print_minmax

    ; Преобразуем double в целое для печати
    fld qword [row_sums + rcx*8]
    fistp dword [rsp]         ; Используем выделенное место, а не rsp-4
    mov edx, [rsp]            ; получаем целое число
    
    mov edi, fmt_sum
    mov esi, ecx                ; номер строки
    xor eax, eax                ; нет векторных аргументов
    push rcx                    ; сохраняем счетчик
    call printf
    pop rcx                     ; восстанавливаем счетчик

    inc rcx
    jmp print_sums_loop

print_minmax:
    ; Вывод минимума
    fld qword [row_sums+40]     ; min
    fistp dword [rsp]           ; Исправлено - используем выделенное место
    mov esi, [rsp]
    
    mov edi, fmt_min
    xor eax, eax
    call printf

    ; Вывод максимума
    fld qword [row_sums+48]     ; max
    fistp dword [rsp]           ; Исправлено - используем выделенное место
    mov esi, [rsp]
    
    mov edi, fmt_max
    xor eax, eax
    call printf

_exit:
    mov rsp, rbp                ; Восстанавливаем исходный указатель стека
    pop rbp
    xor eax, eax                ; return 0
    ret