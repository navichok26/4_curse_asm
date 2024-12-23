; filepath: /home/x5113nc3x/repos/4_curse_asm/true_6.asm
; nasm -f elf64 true_6.asm -o true_6.o
; gcc true_6.o -o true_6 -no-pie
; ./true_6

section .data
    fmtN      db "Input n: ",0
    fmtRead   db "Matrix[%d][%d]: ",0
    fmtSum    db "Sum = %lld",10,0
    fmtInt    db "%d",0

section .bss
    ; Глобальный буфер для матрицы (макс. 10*10 = 100 int)
    matrix  resd 100

section .text
    global main
    extern printf, scanf, abs

;----------------------------------------------------------------------------
;  Стековые переменные (offset от rbp):
;   [rbp-4]  => n (int, 32 бита)
;   [rbp-8]  => выравнивание (не используем)
;   [rbp-16] => sum (qword, 64 бита)
;   [rbp-24] => i   (qword, 64 бита)
;   [rbp-32] => j   (qword, 64 бита)
;   [rbp-36] => выравнивание (не используем)
;   [rbp-40] => center (int, 32 бита)
;   [rbp-48] => temp (qword, 64 бита)
;----------------------------------------------------------------------------
;  Шаги программы:
;   1. Считать n
;   2. Считать матрицу n×n (не более 10×10) в global matrix
;   3. Посчитать сумму элементов, где |i - center| + |j - center| <= center
;   4. Вывести сумму
;   5. Завершиться
;----------------------------------------------------------------------------

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 48                    ; резервируем место под локальные

    ; 1) Считать n
    lea  rdi, [rel fmtN]
    xor  rax, rax
    call printf

    lea  rdi, [rel fmtInt]
    lea  rsi, [rbp-4]              ; n (int)
    xor  rax, rax
    call scanf

    ; sum = 0 (64 бита)
    xor  rax, rax
    mov  [rbp-16], rax

    ; 2) Считать матрицу
    ; i = 0
    xor  rax, rax
    mov  [rbp-24], rax

.read_i_loop:
    mov  rax, [rbp-24]            ; i (qword)
    ; загрузим n как dword
    mov  edx, [rbp-4]
    ; сравниваем i (64 бита) с n (32 бита в edx => 64 бита с 0 в старших)
    cmp  rax, rdx
    jge  .calc_sum                ; если i >= n => переходим к сумме

    ; j = 0
    xor  rcx, rcx
    mov  [rbp-32], rcx

.read_j_loop:
    mov  rcx, [rbp-32]            ; j (qword)
    mov  edx, [rbp-4]             ; n (int) в edx
    cmp  rcx, rdx
    jge  .inc_i

    ; printf("Matrix[i][j]: ")
    lea  rdi, [rel fmtRead]
    ; i (64 бит) => rsi
    mov  rsi, rax
    ; j (64 бит) => rdx
    mov  rdx, rcx
    xor  r10, r10
    xor  r8, r8
    call printf

    ; scanf("%d", &matrix[i*n + j])
    lea  rdi, [rel fmtInt]
    ; вычисляем offset = (i*n + j)*4
    ; i в rax, n в edx => i*n
    mov  r8, rax        ; r8 = i
    imul r8, rdx        ; i*n
    add  r8, rcx        ; i*n + j
    imul r8, 4          ; *4
    lea  rsi, [matrix + r8]
    xor  rax, rax
    call scanf

    ; j++
    mov  rcx, [rbp-32]
    inc  rcx
    mov  [rbp-32], rcx
    jmp  .read_j_loop

.inc_i:
    mov  rax, [rbp-24]
    inc  rax
    mov  [rbp-24], rax
    jmp  .read_i_loop

; 3) Расчет суммы
.calc_sum:
    ; center = n / 2 (32-битное деление)
    mov  eax, [rbp-4]
    shr  eax, 1
    mov  [rbp-40], eax

    ; i = 0
    xor  rax, rax
    mov  [rbp-24], rax

.sum_i_loop:
    mov  rax, [rbp-24]      ; i (qword)
    mov  edx, [rbp-4]       ; n (int -> edx)
    cmp  rax, rdx
    jge  .print_sum

    ; j = 0
    xor  rcx, rcx
    mov  [rbp-32], rcx

.sum_j_loop:
    mov  rcx, [rbp-32]      ; j (qword)
    mov  edx, [rbp-4]       ; n (int -> edx)
    cmp  rcx, rdx
    jge  .inc_i_sum

    ; temp = abs(i - center)
    ; т.к. center - int(32), i - qword(64)
    mov  r8, [rbp-24]       ; i
    mov  edx, [rbp-40]      ; center (32)
    ; r8 - edx => надо привести edx к 64, старшие биты = 0
    ; вычесть => можно сначала сдвинуть r8d
    mov  eax, r8d           ; взять нижние 32 бита i
    sub  eax, edx           ; eax = (int)i - center
    mov  edi, eax
    call abs
    mov  [rbp-48], rax      ; temp (qword)

    ; temp += abs(j - center)
    mov  eax, rcxd          ; j (нижние 32 бита)
    mov  edx, [rbp-40]      ; center
    sub  eax, edx
    mov  edi, eax
    call abs
    add  [rbp-48], rax

    ; Сравнить temp <= center
    ; temp (qword) -> rax
    mov  rax, [rbp-48]
    xor  rdx, rdx
    mov  edx, [rbp-40]      ; center (32)
    cmp  rax, rdx           ; сравниваем temp (64) и center(64, но верх нули)
    jg   .skip_elt

    ; sum += matrix[i*n + j]
    mov  r8, [rbp-24]       ; i (qword)
    mov  edx, [rbp-4]       ; n (int)
    imul r8, rdx            ; i*n
    add  r8, rcx            ; + j
    imul r8, 4              ; * sizeof(int)
    ; загрузим элемент matrix[i][j]
    mov  eax, [matrix + r8]
    cdqe                     ; расширим int -> 64 бит
    ; sum (qword) += rax
    mov  rdx, [rbp-16]       ; rdx = sum
    add  rdx, rax
    mov  [rbp-16], rdx       ; sum = rdx

.skip_elt:
    ; j++
    mov  rax, [rbp-32]
    inc  rax
    mov  [rbp-32], rax
    jmp  .sum_j_loop

.inc_i_sum:
    mov  rax, [rbp-24]
    inc  rax
    mov  [rbp-24], rax
    jmp  .sum_i_loop

; 4) Вывод результата
.print_sum:
    lea  rdi, [rel fmtSum]
    mov  rax, [rbp-16]      ; sum (qword)
    ; Вывод с типом %lld => sum передаём в rsi
    mov  rsi, rax
    xor  rax, rax
    call printf

    ; Возврат 0
    xor  rax, rax
    leave
    ret