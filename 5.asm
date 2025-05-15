BITS 64

section .data
    prompt_msg      db "Enter a natural number: ", 0
    factors_msg     db "Prime factors: ", 0
    k_msg           db "Number of prime factors (K): %d", 10, 0

    scanf_fmt       db "%llu", 0            
    printf_fmt      db "%llu ", 0       
    newline         db 10, 0       
    
section .bss
    number          resq 1                  ; Input number (64-bit)
    k               resd 1                  ; Counter K (32-bit)

section .text
    extern printf
    extern scanf
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov dword [k], 0

    lea rdi, [prompt_msg]  
    xor rax, rax        
    call printf

    lea rdi, [scanf_fmt]  
    lea rsi, [number]    
    xor rax, rax  
    call scanf

    ; Load number into r10 for manipulation
    mov r10, [number]

    ; If number is less than 2, skip factorization
    cmp r10, 2
    jl print_k

    lea rdi, [factors_msg]
    xor rax, rax
    call printf

    ; Initialize current_factor to 2
    mov qword [rbp-16], 2

factor_loop:
    mov rcx, qword [rbp-16]     ; rcx = current_factor
    imul rcx, rcx       
    cmp rcx, r10
    jg print_k  

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
    mov r10, qword [rbp-8]      

    ; Continue factoring with the same current_factor
    jmp factor_loop

increment_factor:
    ; Increment current_factor
    inc qword [rbp-16]
    jmp factor_loop

print_k:
    lea rdi, [newline]
    xor rax, rax
    call printf

    ; Print K
    lea rdi, [k_msg]
    mov esi, [k]              
    xor rax, rax
    call printf

end_program:
    mov rax, 60                  ; syscall: exit
    xor rdi, rdi                 ; exit code 0
    syscall