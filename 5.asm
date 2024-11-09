; Prime Factorization Program in NASM x64
; Uses printf and scanf for I/O
BITS 64

section .data
    prompt_msg      db "Enter a natural number: ", 0
    factors_msg     db "Prime factors: ", 0
    k_msg           db "Number of prime factors (K): %d", 10, 0

    scanf_fmt       db "%llu", 0            ; Format for scanf to read 64-bit integer
    printf_fmt      db "%llu ", 0           ; Format for printf to print 64-bit integer
    newline         db 10, 0                ; Newline character

section .bss
    number          resq 1                  ; Input number (64-bit)
    k               resd 1                  ; Counter K (32-bit)

section .text
    extern printf
    extern scanf
    global main

main:
    ; Function Prologue
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Initialize K to 0
    mov dword [k], 0

    ; Prompt the user
    lea rdi, [prompt_msg]    ; First argument: format string
    xor rax, rax                 ; No floating-point arguments
    call printf

    ; Read input number
    lea rdi, [scanf_fmt]     ; First argument: format string
    lea rsi, [number]        ; Second argument: address to store input
    xor rax, rax                 ; No floating-point arguments
    call scanf

    ; Load number into r10 for manipulation
    mov r10, [number]

    ; If number is less than 2, skip factorization
    cmp r10, 2
    jl print_k

    ; Display "Prime factors: "
    lea rdi, [factors_msg]
    xor rax, rax
    call printf

    ; Initialize current_factor to 2
    mov qword [rbp-16], 2

factor_loop:
    ; Check if current_factor * current_factor <= number
    mov rcx, qword [rbp-16]     ; rcx = current_factor
    imul rcx, rcx              ; rcx = current_factor^2
    cmp rcx, r10
    jg check_remaining         ; If current_factor^2 > number, check remaining number

    ; Check if number is divisible by current_factor
    mov rax, r10
    xor rdx, rdx
    div qword [rbp-16]                     ; rax = r10 / rbx, rdx = r10 % rbx
    mov qword [rbp-8], rax

    cmp rdx, 0
    jne increment_factor        ; If not divisible, try next factor

    ; Divisible: Print the current factor
    lea rdi, [printf_fmt]
    mov rsi, qword [rbp-16]                ; Second argument: current_factor
    xor rax, rax
    call printf

    ; Increment K
    mov eax, [k]
    inc eax
    mov [k], eax

    ; Update number = number / current_factor
    mov r10, qword [rbp-8]                ; r10 = quotient

    ; Continue factoring with the same current_factor
    jmp factor_loop

increment_factor:
    ; Increment current_factor
    inc qword [rbp-16]
    jmp factor_loop

check_remaining:
    ; If number > 1, it's a prime factor
    cmp r10, 1
    jle print_k                 ; If number <=1, skip

    ; Print the remaining prime factor
    lea rdi, [printf_fmt]
    mov rsi, r10
    xor rax, rax
    call printf

    ; Increment K
    mov eax, [k]
    inc eax
    mov [k], eax

print_k:
    ; Print newline
    lea rdi, [newline]
    xor rax, rax
    call printf

    ; Print K
    lea rdi, [k_msg]
    mov esi, [k]                ; Second argument: K (as 32-bit integer)
    xor rax, rax
    call printf

end_program:
    ; Function Epilogue and exit via syscall
    mov rax, 60                  ; syscall: exit
    xor rdi, rdi                 ; exit code 0
    syscall