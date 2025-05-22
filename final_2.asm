section .data
    matrix dq 1.2, -2.3, 3.4, 4.5, -5.6
           dq 2.1, 3.2, -4.3, 5.4, 6.5
           dq -1.1, 2.2, 3.3, -4.4, 5.5
           dq 6.6, -7.7, 8.8, 9.9, -10.1
           dq 1.0, 2.0, 3.0, 4.0, 5.0

    fmt_sum db "Sum of row %d: %ld", 10, 0

section .bss
    row_sums resq 5

section .text
    extern printf
    global main

main:
    push rbp

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
    jge _exit

    mov rax, [row_sums + rcx*8]
    mov rsi, rcx
    mov rdx, rax
    mov rdi, fmt_sum
    xor eax, eax
    push rcx            ; сохранить счётчик
    call printf
    pop rcx             ; восстановить счётчик

    inc rcx
    jmp print_sums_loop

_exit:
    pop rbp
    ret