; hex-to-binary-octal-emu8086-working.asm
org 100h

start:
    ; make DS point to our code/data segment (safe for COM)
    push cs
    pop ds

prompt_loop:
    ; prompt
    lea dx, msgPrompt
    mov ah, 09h
    int 21h

    ; read DOS buffered input: [max][len][chars...]
    lea dx, inputBuf
    mov ah, 0Ah
    int 21h

    ; length (byte) -> CL, clear CH
    mov cl, [inputBuf+1]
    xor ch, ch
    cmp cl, 0
    je prompt_loop         ; nothing entered -> reprompt
    cmp cl, 4
    ja too_long            ; shouldn't happen because buffer max = 4, but check anyway

    ; save length
    mov [lenCount], cl

    ; set SI to first char
    lea si, inputBuf+2

    ; accumulator (word) in BX
    xor bx, bx

    ; set CX = length for loop
    mov cx, 0
    mov cl, [lenCount]

convert_loop:
    mov al, [si]           ; current character

    ; validate and convert ascii -> 0..15 in AL
    cmp al, '0'
    jb invalid_input
    cmp al, '9'
    jbe is_digit
    cmp al, 'A'
    jb check_lower
    cmp al, 'F'
    jbe is_upper
    cmp al, 'a'
    jb invalid_input
    cmp al, 'f'
    jbe is_lower
    jmp invalid_input

is_digit:
    sub al, '0'
    jmp got_nibble
is_upper:
    sub al, 'A'
    add al, 10
    jmp got_nibble
is_lower:
    sub al, 'a'
    add al, 10
    jmp got_nibble
check_lower:
    jmp invalid_input

got_nibble:
    and al, 0Fh            ; AL = nibble (0..15)
    xor ah, ah

    ; shift BX left 4 bits (multiply by 16)
    shl bx, 1
    shl bx, 1
    shl bx, 1
    shl bx, 1

    ; add nibble (AX contains nibble)
    add bx, ax

    inc si
    loop convert_loop

    ; BX now contains numeric value

    ; ---- print binary ----
    lea dx, msgBinary
    mov ah, 09h
    int 21h

    ; compute bitsCount = len * 4 in CX
    mov cl, [lenCount]
    xor ch, ch
    shl cx, 1
    shl cx, 1        ; cx = length * 4  (1..16)

    ; build mask in DX = 1 << (bitsCount-1)
    mov dx, 1
    mov si, cx
    dec si
    cmp si, 0
    je mask_ready
mask_build:
    shl dx, 1
    dec si
    jnz mask_build
mask_ready:

    ; print bitsCount bits from msb->lsb
print_bits:
    ; CX is bitsCount counter
    test bx, dx
    jnz bit_is_one
    mov dl, '0'
    jmp out_bit
bit_is_one:
    mov dl, '1'
out_bit:
    mov ah, 02h
    int 21h
    shr dx, 1
    loop print_bits

    ; CR LF
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h

    ; ---- print octal ----
    lea dx, msgOctal
    mov ah, 09h
    int 21h

    ; convert BX -> octal by repeated divide-by-8 (DX:AX / 8)
    mov ax, bx
    cmp ax, 0
    jne do_octal
    ; special-case zero
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp done_prints

do_octal:
    xor cx, cx            ; digit count
oct_div_loop:
    xor dx, dx
    mov si, 8
    div si                ; DX = remainder, AX = quotient
    push dx               ; push remainder (word)
    inc cx
    cmp ax, 0
    jne oct_div_loop

print_oct_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    dec cx
    jnz print_oct_loop

done_prints:
    ; final newline
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    mov ah, 02h
    int 21h

    ; exit normally
    mov ah, 4Ch
    int 21h

invalid_input:
    lea dx, msgInvalid
    mov ah, 09h
    int 21h
    ; wait key then reprompt
    mov ah, 0
    int 16h
    jmp prompt_loop

too_long:
    lea dx, msgTooLong
    mov ah, 09h
    int 21h
    mov ah, 0
    int 16h
    jmp prompt_loop

; -----------------------
; data
; -----------------------
msgPrompt  db 0Dh,0Ah,'enter hex (1-4 digits): $'
msgInvalid db 0Dh,0Ah,'invalid hex! only 0-9,A-F,a-f. press any key to retry.$'
msgTooLong db 0Dh,0Ah,'too long (max 4 digits). press any key to retry.$'
msgBinary  db 0Dh,0Ah,'binary : $'
msgOctal   db 0Dh,0Ah,'octal  : $'

inputBuf   db 4, 0, 4 dup(0)   ; max=4, len byte, then 4 chars
lenCount   db 0

; end
