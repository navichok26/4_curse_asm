; NASM x64 program for Linux
; Removes a group of 5 consecutive elements whose sum equals K from an array

section .data
    prompt_n        db 'Enter the number of elements (N >= 5): ', 0
    prompt_elements db 'Enter the elements separated by spaces:', 10, 0
    prompt_k        db 'Enter the value of K: ', 0
    result_msg      db 'Resulting array:', 10, 0
    scanf_fmt_int   db '%lld', 0                ; For 64-bit integers
    printf_fmt_int  db '%lld ', 0               ; For 64-bit integers
    error_msg       db 'Error', 10, 0
    newline         db 10, 0

section .bss
    array           resq 100                   ; Array of 100 8-byte integers

section .text
    global main
    extern printf
    extern scanf

main:
    ; Function prologue
    push rbp
    mov rbp, rsp
    sub rsp, 64                        ; Reserve 56 bytes for variables
    ; Variables on the stack:
    ; [rbp-8]   => n           (qword)
    ; [rbp-16]  => k           (qword)
    ; [rbp-24]  => i           (qword)
    ; [rbp-32]  => sum         (qword)
    ; [rbp-40]  => found       (qword)
    ; [rbp-48]  => n_original  (qword)

    ; Initialize 'found' to 0
    mov qword [rbp-40], 0

    ; Prompt for N
    lea rdi, [rel prompt_n]
    xor rax, rax
    call printf

    ; Read N
    lea rdi, [rel scanf_fmt_int]
    lea rsi, [rbp-8]                    ; Address of n
    xor rax, rax
    call scanf

    ; Check if N >= 5
    mov rax, qword [rbp-8]
    cmp rax, 5
    jl .exit_program

    ; Save original N
    mov qword [rbp-48], rax             ; n_original = n

    ; Prompt for elements
    lea rdi, [rel prompt_elements]
    xor rax, rax
    call printf

    ; Initialize i to 0
    mov qword [rbp-24], 0

.read_elements_loop:
    mov rax, qword [rbp-24]             ; i
    mov rbx, qword [rbp-8]              ; n
    cmp rax, rbx
    jge .read_k                          ; If i >= n, read K

    ; Read element into array[i]
    lea rdi, [rel scanf_fmt_int]
    mov rsi, array
    mov rdx, rax                        ; rdx = i
    shl rdx, 3                          ; rdx = i * 8
    add rsi, rdx                        ; rsi = &array[i]
    xor rax, rax
    call scanf

    inc qword [rbp-24]
    jmp .read_elements_loop

.read_k:
    ; Prompt for K
    lea rdi, [rel prompt_k]
    xor rax, rax
    call printf

    ; Read K
    lea rdi, [rel scanf_fmt_int]
    lea rsi, [rbp-16]                    ; Address of k
    xor rax, rax
    call scanf

    ; Reset i to 0 for searching
    mov qword [rbp-24], 0

.find_group_loop:
    mov rax, qword [rbp-24]             ; i
    mov rbx, qword [rbp-8]              ; n
    sub rbx, 5                           ; rbx = n - 5
    cmp rax, rbx
    jg .output_result                    ; If i > n - 5, exit loop

    ; Calculate sum of array[i] to array[i+4]
    mov qword [rbp-32], 0                 ; sum = 0
    mov rcx, 0                            ; counter = 0

.sum_loop:
    cmp rcx, 5
    jge .check_sum

    mov rdx, qword [rbp-24]               ; i
    add rdx, rcx                          ; index = i + counter
    lea rsi, [array + rdx*8]              ; rsi = &array[index]
    mov rdx, qword [rsi]                  ; array[index]
    add qword [rbp-32], rdx               ; sum += array[index]
    inc rcx
    jmp .sum_loop

.check_sum:
    mov rax, qword [rbp-32]               ; sum
    mov rbx, qword [rbp-16]               ; k
    cmp rax, rbx
    jne .next_i

    ; Group found
    mov qword [rbp-40], 1                 ; found = 1

    ; Save original N if not already saved
    ; (Already saved before)

    ; Shift elements to remove the group
    mov rcx, qword [rbp-24]               ; source index = i + 5
    add rcx, 5
    mov rdi, qword [rbp-24]               ; destination index = i

.shift_loop:
    mov rax, qword [rbp-48]               ; n_original
    cmp rcx, rax
    jge .update_n                         ; If source >= n_original, done shifting

    lea rsi, [array + rcx*8]              ; rsi = &array[source]
    mov rax, qword [rsi]                  ; temp = array[source]

    lea rdx, [array + rdi*8]              ; rdx = &array[dest]
    mov qword [rdx], rax                  ; array[dest] = temp

    inc rcx                               ; source index++
    inc rdi                               ; destination index++
    jmp .shift_loop

.update_n:
    ; Update N after shifting
    mov rax, qword [rbp-8]
    sub rax, 5                            ; n = n - 5
    mov qword [rbp-8], rax

    jmp .output_result

.next_i:
    inc qword [rbp-24]
    jmp .find_group_loop

.output_result:
    ; Check if a group was found
    mov rax, qword [rbp-40]
    cmp rax, 0
    je .no_group_found

    ; Print the resulting array
    lea rdi, [rel result_msg]
    xor rax, rax
    call printf

    mov qword [rbp-24], 0                 ; i = 0

.print_loop:
    mov rax, qword [rbp-24]               ; i
    mov rbx, qword [rbp-8]                ; n
    cmp rax, rbx
    jge .end_program

    lea rdi, [rel printf_fmt_int]
    mov rsi, array
    mov rdx, rax
    shl rdx, 3
    add rsi, rdx                          ; rsi = &array[i]
    mov rax, qword [rsi]                  ; array[i]
    mov rsi, rax                          ; Move value to rsi for printf
    xor rax, rax
    call printf

    inc qword [rbp-24]
    jmp .print_loop

.no_group_found:
    lea rdi, [rel error_msg]
    xor rax, rax
    call printf

.end_program:
    ; Print newline
    lea rdi, [rel newline]
    xor rax, rax
    call printf

    ; Function epilogue and exit
    mov rsp, rbp
    pop rbp
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; exit code 0
    syscall

.exit_program:
    ; Function epilogue and exit
    mov rsp, rbp
    pop rbp
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; exit code 0
    syscall