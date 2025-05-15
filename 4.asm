BITS 64

section .data
    prompt_fmt db "Enter a natural number: ", 0
    divisors_fmt db "Divisors:", 0xA, 0
    perfect_fmt db "The number is perfect.", 0xa, 0
    not_perfect_fmt db "The number is not perfect.", 0xa, 0
    number_fmt db "%llu", 0
    newline db 10, 0

section .bss
    number resq 1
    sum resq 1
    i resq 1

section .text
    extern printf
    extern scanf

global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov qword [sum], 0
    mov qword [i], 1

    mov rdi, prompt_fmt
    xor rax, rax
    call printf

    mov rdi, number_fmt
    lea rsi, [number]
    xor rax, rax
    call scanf

    mov rdi, divisors_fmt
    xor rax, rax
    call printf

div_loop:
    mov rax, [i]
    mov rbx, [number]
    cmp rax, rbx
    jge check_perfect

    xor rdx, rdx
    mov rax, [number]
    mov rbx, [i]
    div rbx
    cmp rdx, 0
    jne next_divisor

    ; Add to sum
    mov rax, [sum]
    add rax, [i]
    mov qword [sum], rax

    mov rdi, number_fmt
    mov rsi, [i]
    xor rax, rax
    call printf

    mov rdi, newline
    xor rax, rax
    call printf

next_divisor:
    inc qword [i]
    jmp div_loop

check_perfect:
    mov rdi, newline
    xor rax, rax
    call printf

    mov rax, [sum]
    mov rbx, [number]
    cmp rax, rbx
    jne not_perfect

    mov rdi, perfect_fmt
    xor rax, rax
    call printf
    jmp exit_program

not_perfect:
    mov rdi, not_perfect_fmt
    xor rax, rax
    call printf

exit_program:
    mov rax, 60 
    xor rdi, rdi 
    syscall
