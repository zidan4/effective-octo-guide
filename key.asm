
section .bss
    key resb 17    ; Buffer for the key (16 characters + null terminator)

section .text
    global _start
    extern srand, rand  ; If we need a fallback using C functions (not used here)

_start:
    mov rdi, key
    mov rcx, 16      ; Generate 16 characters

generate_loop:
    ; Use RDRAND (hardware RNG)
    rdrand rax
    jnc fallback     ; If RDRAND fails, use fallback method
    and al, 0x3F     ; Limit to 64 values (0-9, A-Z, a-z, special)
    
    cmp al, 10
    jl  num_case     ; If < 10, it's a digit (0-9)
    cmp al, 36
    jl  upper_case   ; If < 36, it's an uppercase letter (A-Z)
    
    add al, 61       ; Convert remaining values to lowercase letters (a-z)
    jmp store_char

num_case:
    add al, '0'      ; Convert 0-9
    jmp store_char

upper_case:
    add al, 'A' - 10 ; Convert 10-35 to A-Z
    jmp store_char

store_char:
    mov [rdi], al
    inc rdi
    loop generate_loop

    mov byte [rdi], 0  ; Null-terminate the string

    ; Print the key
    mov rsi, key
    mov rdx, 16        ; Length
    mov rax, 1         ; Syscall: write
    mov rdi, 1         ; File descriptor: stdout
    syscall

    ; Exit program
    mov rax, 60        ; Syscall: exit
    xor rdi, rdi       ; Exit status 0
    syscall

fallback:
    ; Fallback to /dev/urandom if RDRAND fails
    mov rax, 2         ; Syscall: open
    mov rdi, urandom   ; Path: /dev/urandom
    mov rsi, 0         ; Read-only
    syscall
    mov rdi, rax       ; File descriptor

    mov rax, 0         ; Syscall: read
    mov rsi, key       ; Buffer
    mov rdx, 16        ; Read 16 bytes
    syscall

    ; Close file
    mov rax, 3
    syscall

    jmp generate_loop  ; Go back to convert bytes

section .data
    urandom db "/dev/urandom", 0
