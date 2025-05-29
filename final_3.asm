global main
extern printf
extern scanf

section .data
    fmt_scan:    db "%32s", 0
    fmt_out:     db "Количество несовпадающих разрядов: %u", 10, 0

section .bss
    buf1:        resb 33
    buf2:        resb 33

section .text
main:
    ; prologue: выравниваем RSP на 16-байтную границу
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16

    ; Ввод первого битового вектора как строки
    lea     rdi, [rel fmt_scan]
    lea     rsi, [rel buf1]
    xor     rax, rax
    call    scanf

    ; Ввод второго битового вектора как строки
    lea     rdi, [rel fmt_scan]
    lea     rsi, [rel buf2]
    xor     rax, rax
    call    scanf

    ; Преобразование строки buf1 в unsigned int в RDX
    xor     rdx, rdx        ; rdx = 0
    lea     rsi, [rel buf1]
parse1:
    mov     al, [rsi]
    cmp     al, 0
    je      parse2
    shl     rdx, 1
    cmp     al, '1'
    jne     .skip1
    or      rdx, 1
.skip1:
    inc     rsi
    jmp     parse1

    ; Преобразование строки buf2 в unsigned int в RCX
parse2:
    xor     rcx, rcx        ; rcx = 0
    lea     rsi, [rel buf2]
parse2_loop:
    mov     al, [rsi]
    cmp     al, 0
    je      compute
    shl     rcx, 1
    cmp     al, '1'
    jne     .skip2
    or      rcx, 1
.skip2:
    inc     rsi
    jmp     parse2_loop

    ; XOR для получения маски несовпадающих битов
compute:
    mov     rax, rdx
    xor     rax, rcx        ; rax = разность битов

    ; Подсчёт единичных битов в RAX
    xor     rbx, rbx        ; счётчик = 0
count_loop:
    test    rax, rax
    je      output
    test    rax, 1
    jz      .no_inc
    inc     rbx
.no_inc:
    shr     rax, 1
    jmp     count_loop

    ; Вывод результата
output:
    lea     rdi, [rel fmt_out]
    mov     esi, ebx
    xor     eax, eax
    call    printf

    ; epilogue: восстанавливаем стек
    xor     eax, eax
    leave
    ret