section .data
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
    row_sums resq 6 

section .text
    extern printf
    global main

main:
    push rbp
    mov rbp, rsp
    and rsp, -16      
    sub rsp, 40 

    mov rcx, 0
rowsum_loop:
    cmp rcx, 5
    jge rowsum_done

    mov rbx, rcx
    imul rbx, 5 ; размер матрицы
    mov rsi, rbx
    imul rsi, 8 ; размер ячейки
    lea rdi, [matrix + rsi]

    ; сумма элементов строки
    fld qword [rdi]
    fld qword [rdi+8]
    faddp st1, st0
    fld qword [rdi+16]
    faddp st1, st0
    fld qword [rdi+24]
    faddp st1, st0
    fld qword [rdi+32]
    faddp st1, st0

    ; сохраняем
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
    jbe .skip_max               ; если сумма <= max, пропускаем
    fstp st0                    ; убираем max со стека
    fstp qword [row_sums+48]    ; сохраняем новый max
    jmp .after_max
.skip_max:
    fstp st0                    ; убираем max со стека
    fstp st0                    ; убираем сумму со стека
.after_max:

    fld qword [row_sums + rcx*8]
    fld qword [row_sums+40]     ; min
    fcomi st0, st1
    jae .skip_min               ; если сумма >= min, пропускаем
    fstp st0                    
    fstp qword [row_sums+40]    
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

    ; Передаем double через стек
    mov rdi, fmt_sum
    mov rsi, rcx                ; номер строки
    fld qword [row_sums + rcx*8]
    fstp qword [rsp]           ; Сохраняем double на стеке
    movsd xmm0, [rsp]          ; Загружаем в xmm0 для printf
    mov eax, 1                  ; 1 xmm-регистр используется
    push rcx
    call printf
    pop rcx

    inc rcx
    jmp print_sums_loop

print_minmax:
    ; Вывод минимума
    mov rdi, fmt_min
    fld qword [row_sums+40]     ; min
    fstp qword [rsp]
    movsd xmm0, [rsp]
    mov eax, 1                  
    sub rsp, 8                  
    call printf
    add rsp, 8                 

    ; Вывод максимума
    mov rdi, fmt_max
    fld qword [row_sums+48]     ; max
    fstp qword [rsp]
    movsd xmm0, [rsp]
    mov eax, 1                 
    sub rsp, 8                  
    call printf
    add rsp, 8                 

    ; Вывод натурального логарифма abs(сумм)
    mov rcx, 0
ln_loop:
    cmp rcx, 5
    jge _exit

    ; ln(abs(sum))
    fld qword [row_sums + rcx*8]
    fabs                        ; abs(sum)
    fldln2                      ; загрузка ln(2)
    fxch                        
    fyl2x                       ; st0 = ln(abs(sum))
    
    fstp qword [rsp]            ; Сохраняем результат
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