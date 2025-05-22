section .data
    rows dq 5
    cols dq 5
    matrix dq 1.2, -2.3, 3.4, 4.5, -5.6
           dq 2.1, 3.2, -4.3, 5.4, 6.5
           dq -1.1, 2.2, 3.3, -4.4, 5.5
           dq 6.6, -7.7, 8.8, 9.9, -10.1
           dq 1.0, 2.0, 3.0, 4.0, 5.0

    fmt_sum db "Sum of row %d: %.2f", 10, 0
    fmt_min db "Max sum: %.2f", 10, 0
    fmt_max db "Min sum: %.2f", 10, 0
    fmt_ln  db "ln(abs(sum row %d)): %.6f", 10, 0

section .bss
    row_sums resq 32    ; запас для больших матриц

section .text
    extern printf
    global main

main:
    push rbp
    mov rbp, rsp
    and rsp, -16      
    sub rsp, 40 

    mov rcx, 0
    mov r8, [rows]
    mov r9, [cols]
rowsum_loop:
    cmp rcx, r8
    jge rowsum_done

    mov rbx, rcx
    imul rbx, r9                ; rbx = номер строки * cols
    mov rsi, rbx
    imul rsi, 8                 ; rsi = смещение в байтах
    lea rdi, [matrix + rsi]

    ; сумма элементов строки
    mov rdx, 0                  ; столбец
    fldz                        ; st0 = 0.0
sum_row_loop:
    cmp rdx, r9
    jge sum_row_done
    fld qword [rdi + rdx*8]
    faddp st1, st0
    inc rdx
    jmp sum_row_loop
sum_row_done:
    fstp qword [row_sums + rcx*8]

    inc rcx
    jmp rowsum_loop
rowsum_done:

    ; min/max
    mov rcx, 0
    fld qword [row_sums]
    fstp qword [row_sums + r8*8]    ; min (после всех сумм)
    fld qword [row_sums]
    fstp qword [row_sums + r8*8 + 8] ; max (ещё дальше)

find_minmax_loop:
    inc rcx
    cmp rcx, r8
    jge find_minmax_done

    fld qword [row_sums + rcx*8]
    fld qword [row_sums + r8*8 + 8]     ; max
    fcomi st0, st1
    jbe .skip_max
    fstp st0
    fstp qword [row_sums + r8*8 + 8]
    jmp .after_max
.skip_max:
    fstp st0
    fstp st0
.after_max:

    fld qword [row_sums + rcx*8]
    fld qword [row_sums + r8*8]     ; min
    fcomi st0, st1
    jae .skip_min
    fstp st0
    fstp qword [row_sums + r8*8]
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
    cmp rcx, r8
    jge print_minmax

    mov rdi, fmt_sum
    mov rsi, rcx
    fld qword [row_sums + rcx*8]
    fstp qword [rsp]
    movsd xmm0, [rsp]
    mov eax, 1
    push rcx
    call printf
    pop rcx

    inc rcx
    jmp print_sums_loop

print_minmax:
    ; Вывод минимума
    mov rdi, fmt_min
    fld qword [row_sums + r8*8]     ; min
    fstp qword [rsp]
    movsd xmm0, [rsp]
    mov eax, 1
    sub rsp, 8
    call printf
    add rsp, 8

    ; Вывод максимума
    mov rdi, fmt_max
    fld qword [row_sums + r8*8 + 8] ; max
    fstp qword [rsp]
    movsd xmm0, [rsp]
    mov eax, 1
    sub rsp, 8
    call printf
    add rsp, 8

    ; Вывод натурального логарифма abs(сумм)
    mov rcx, 0
ln_loop:
    cmp rcx, r8
    jge _exit

    fld qword [row_sums + rcx*8]
    fabs
    fldln2
    fxch
    fyl2x

    fstp qword [rsp]
    movsd xmm0, [rsp]

    mov rdi, fmt_ln
    mov rsi, rcx
    mov eax, 1
    push rcx
    call printf
    pop rcx

    inc rcx
    jmp ln_loop

_exit:
    mov rsp, rbp
    pop rbp
    xor eax, eax              
    ret