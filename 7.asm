; filepath: /home/x5113nc3x/repos/4_curse_asm/7.asm
section .data
    prompt       db "Enter a binary number (up to 32 bits): ", 0
    format_in    db "%32s", 0
    format_out   db "Reversed bits: %s", 10, 0

section .bss
    input_buffer    resb 33          ; Buffer for input string (32 bits + null)
    reversed_buffer resb 33          ; Buffer for reversed string

section .text
    extern printf, scanf
    global main

main:
    ; Set up stack frame
    push rbp
    mov rbp, rsp
    sub rsp, 64

    ; Print prompt
    lea rdi, [rel prompt]
    xor eax, eax
    call printf

    ; Read input string
    lea rsi, [rel input_buffer]
    lea rdi, [rel format_in]
    xor eax, eax
    call scanf

    ; Compute string length
    lea rsi, [rel input_buffer]    ; Source pointer
    xor rcx, rcx                   ; RCX will hold the length
count_len:
    cmp byte [rsi + rcx], 0
    je len_done
    inc rcx
    jmp count_len
len_done:
    ; RCX now contains the length of the input

    ; Push each character onto the stack (from start to end)
    xor rdi, rdi                   ; Initialize index to 0
reverse_push:
    cmp rdi, rcx
    je reverse_done_push
    mov al, [rsi + rdi]
    movzx rax, al                  ; Zero-extend AL to RAX
    push rax                        ; Push the character
    inc rdi
    jmp reverse_push
reverse_done_push:

    ; Pop each character from the stack into reversed_buffer
    lea rdi, [rel reversed_buffer]   ; Destination pointer
    mov rdx, rcx                     ; Store length in RDX for loop counter
reverse_pop:
    cmp rcx, 0
    je reverse_done_pop
    pop rax
    mov [rdi], al                    ; Write character to reversed_buffer
    inc rdi
    dec rcx
    jmp reverse_pop
reverse_done_pop:
    ; Null-terminate the reversed string
    mov byte [rdi], 0

    ; Print reversed string
    lea rsi, [rel reversed_buffer]
    lea rdi, [rel format_out]
    xor eax, eax
    call printf

    ; Clean up and exit
    mov eax, 0
    leave
    ret