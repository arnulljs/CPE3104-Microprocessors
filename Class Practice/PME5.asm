org 100h
jmp start

start:
    push cs
    pop ds

; -----------------------------
; Step 1: Ask user to set a password (visible input)
; -----------------------------
setPassword:
    mov dx, offset setPrompt
    mov ah, 09h
    int 21h

    mov passwordEcho, 0         ; disable '*' for initial setup
    call readMaskedLine          ; read into password buffer
    mov ax, [inlen]
    mov [passlen], ax

; -----------------------------
; Step 2: Ask user to verify password (echo '*')
; -----------------------------
askAgain:
    mov dx, offset prompt
    mov ah, 09h
    int 21h

    mov passwordEcho, 1         ; enable '*' for login
    call readMaskedLine          ; read into inbuf

    ; compare lengths
    mov ax, [passlen]
    cmp ax, [inlen]
    jne badLogin

    ; compare bytes in inbuf to password
    push ds
    pop es
    lea si, password
    lea di, inbuf
    mov cx, [passlen]
    cld
    repe cmpsb
    jnz badLogin

goodLogin:
    mov dx, offset granted
    mov ah, 09h
    int 21h
    jmp done

badLogin:
    mov dx, offset denied
    mov ah, 09h
    int 21h
    ; uncomment to retry login
    ; jmp askAgain

done:
    mov ax, 4C00h
    int 21h

; -----------------------------
; PROCEDURE: readMaskedLine
; -----------------------------
; Uses passwordEcho=0 to show typed chars, =1 to show '*'
readMaskedLine:
    push ax
    push bx
    push cx
    push dx
    push si

    ; decide where to store input
    cmp passwordSet, 0
    je storePassword
    lea si, inbuf
    jmp readChars

storePassword:
    lea si, password
    mov passwordSet, 1

readChars:
    xor bx, bx             ; bx = length

readNextChar:
    mov ah, 08h            ; read char, no echo
    int 21h
    cmp al, 13             ; Enter?
    je doneReading

    cmp al, 8              ; Backspace?
    jne normalChar

    cmp bx, 0
    jz readNextChar
    dec bx
    dec si
    ; erase character visually
    mov dl, 8
    mov ah, 02h
    int 21h
    mov dl, ' '
    mov ah, 02h
    int 21h
    mov dl, 8
    mov ah, 02h
    int 21h
    jmp readNextChar

normalChar:
    cmp bx, 32
    jae readNextChar
    mov [si], al
    inc si
    inc bx
    cmp passwordEcho, 0
    je showCharDirect
    mov dl, '*'
    mov ah, 02h
    int 21h
    jmp readNextChar

showCharDirect:
    mov dl, al             ; show the actual typed character
    mov ah, 02h
    int 21h
    jmp readNextChar

doneReading:
    ; newline after Enter
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h

    mov inlen, bx           ; save input length
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; -----------------------------
; DATA
; -----------------------------
setPrompt    db 'Set your password: $'
prompt       db 'Enter password: $'
granted      db 13,10,'Access Granted',13,10,'$'
denied       db 13,10,'Access Denied',13,10,'$'

password     db 32 dup(0)
passlen      dw 0
inbuf        db 32 dup(0)
inlen        dw 0
passwordSet  db 0
passwordEcho db 0       ; 0=show typed chars, 1=mask with '*'
