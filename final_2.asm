section .data
    matrix dq 1.2, -2.3, 3.4, 4.5, -5.6
           dq 2.1, 3.2, -4.3, 5.4, 6.5
           dq -1.1, 2.2, 3.3, -4.4, 5.5
           dq 6.6, -7.7, 8.8, 9.9, -10.1
           dq 1.0, 2.0, 3.0, 4.0, 5.0

    fmt_sum db "Sum of row %d: ",0
    fmt_min db "Min sum: ",0
    fmt_max db "Max sum: ",0
    fmt_ln  db "ln(abs(sum)): ",0
    newline db 10,0

section .bss
    row_sums resq 5
    buf resb 100

section .text
    global main

main:
    mov rcx, 0              ; row index
rowsum_loop:
    cmp rcx, 5
    jge rowsum_done

    ; Суммируем строку
    mov rbx, rcx
    imul rbx, 5             ; rbx = row * 5
    mov rsi, rbx
    imul rsi, 8             ; rsi = offset в байтах
    lea rdi, [matrix + rsi] ; rdi = адрес начала строки

    fld qword [rdi]         ; st0 = matrix[row][0]
    fld qword [rdi+8]       ; st0 = matrix[row][1], st1 = matrix[row][0]
    faddp st1, st0          ; st0 = sum[0..1]
    fld qword [rdi+16]
    faddp st1, st0
    fld qword [rdi+24]
    faddp st1, st0
    fld qword [rdi+32]
    faddp st1, st0          ; st0 = sum of row

    fstp qword [row_sums + rcx*8] ; сохраняем сумму строки

    inc rcx
    jmp rowsum_loop
rowsum_done:

    ; Ищем min/max
    mov rcx, 0
    fld qword [row_sums]    ; st0 = min
    fld qword [row_sums]    ; st0 = max, st1 = min

find_minmax_loop:
    inc rcx
    cmp rcx, 5
    jge find_minmax_done

    fld qword [row_sums + rcx*8] ; st0 = sum, st1 = max, st2 = min

    ; Для max
    fld st1                 ; st0 = max, st1 = sum, st2 = max, st3 = min
    fcomi st0, st1          ; сравниваем sum и max
    jae .skip_max
    fstp st1                ; если sum > max, max = sum
    jmp .after_max
.skip_max:
    fstp st0                ; иначе просто убрать sum со стека
.after_max:

    ; Для min
    fld st2                 ; st0 = min, st1 = max, st2 = min
    fcomi st0, st2
    jbe .skip_min
    fstp st2                ; если sum < min, min = sum
    jmp .after_min
.skip_min:
    fstp st0
.after_min:

    jmp find_minmax_loop
find_minmax_done:
    ; Теперь st0 = max, st1 = min

    ; Сохраняем min/max
    fstp qword [buf]        ; min
    fstp qword [buf+8]      ; max

    ; Выводим суммы строк
    mov rcx, 0
print_sums_loop:
    cmp rcx, 5
    jge print_minmax

    mov rax, rcx
    add rax, '1'
    mov [buf+16], al
    mov byte [buf+17], 0

    mov rdi, fmt_sum
    mov rsi, buf+16
    call print_str

    movq xmm0, qword [row_sums + rcx*8]
    mov rdi, buf
    call float_to_str
    call print_str

    mov rdi, newline
    call print_str

    inc rcx
    jmp print_sums_loop

print_minmax:
    mov rdi, fmt_min
    call print_str
    movq xmm0, qword [buf]
    mov rdi, buf
    call float_to_str
    call print_str
    call print_nl

    mov rdi, fmt_max
    call print_str
    movq xmm0, qword [buf+8]
    mov rdi, buf
    call float_to_str
    call print_str
    call print_nl

    ; ln(abs(sum))
    mov rcx, 0
ln_loop:
    cmp rcx, 5
    jge _exit

    mov rdi, fmt_ln
    call print_str

    fld qword [row_sums + rcx*8]
    fabs
    fldln2
    fxch
    fyl2x
    fstp qword [buf]
    movq xmm0, qword [buf]
    mov rdi, buf
    call float_to_str
    call print_str
    call print_nl

    inc rcx
    jmp ln_loop

_exit:
    mov rax, 60
    xor rdi, rdi
    syscall

; --- Вспомогательные функции ---

; Вывод строки по адресу rdi (null-terminated)
print_str:
    push rdi
    mov rsi, rdi
    mov rdx, 0
.next:
    cmp byte [rsi+rdx], 0
    je .len_found
    inc rdx
    jmp .next
.len_found:
    mov rax, 1
    mov rdi, 1
    syscall
    pop rdi
    ret

print_nl:
    mov rdi, newline
    call print_str
    ret

; Перевод double в строку (очень простой, 6 знаков после запятой)
; Вход: xmm0 - число, rdi - буфер
float_to_str:
    sub rsp, 32
    movsd [rsp], xmm0
    mov rax, 1
    mov rsi, rsp
    mov rdx, 32
    mov rdi, 1
    syscall
    add rsp, 32
    ret