; Decimal - Binary Octal Hex (camelCase version)

org 100h
    jmp start

prompt      db 'Enter decimal (0-255): $'
nl          db 0Dh,0Ah,'$'
msgBin      db 0Dh,0Ah,'Binary: $'
msgOct      db 0Dh,0Ah,'Octal : $'
msgHex      db 0Dh,0Ah,'Hex   : $'

value       db 0                 ; parsed number 0..255

; nibble -> 4-bit ASCII strings (16 * 4 chars)
bin4Tbl    db '0000','0001','0010','0011'
           db '0100','0101','0110','0111'
           db '1000','1001','1010','1011'
           db '1100','1101','1110','1111'

; hex digits table
hexTbl     db '0123456789ABCDEF'

start:
    push cs
    pop  ds

    ; prompt
    mov dx, offset prompt
    mov ah, 9
    int 21h

    ; -------- read & parse decimal (0..255) --------
    xor bx, bx                 ; BX = accumulator (0..255)
readLoop:
    mov ah, 1
    int 21h
    cmp al, 0Dh                ; Enter?
    je  parseDone
    cmp al, '0'
    jb  readLoop               ; ignore non-digits
    cmp al, '9'
    ja  readLoop
    sub al, '0'                ; AL = digit 0..9
    mov dl, al                 ; save digit in DL

    ; BX = BX*10 + DL
    mov ax, bx
    mov cx, bx
    shl ax, 3                  ; *8
    shl cx, 1                  ; *2
    add ax, cx                 ; *10
    xor cx, cx
    mov cl, dl
    add ax, cx
    mov bx, ax
    jmp readLoop

parseDone:
    ; clamp to 255 just in case
    cmp bx, 255
    jbe storeVal
    mov bx, 255
storeVal:
    mov [value], bl

    ; newline
    mov dx, offset nl
    mov ah, 9
    int 21h

    ; -------- Binary --------
    mov dx, offset msgBin
    mov ah, 9
    int 21h
    call printBin8
    mov dl, 'b'
    mov ah, 2
    int 21h

    ; -------- Octal --------
    mov dx, offset msgOct
    mov ah, 9
    int 21h
    call printOctal
    mov dl, 'o'
    mov ah, 2
    int 21h

    ; -------- Hex --------
    mov dx, offset msgHex
    mov ah, 9
    int 21h
    call printHex2
    mov dl, 'h'
    mov ah, 2
    int 21h

    ; newline and exit
    mov dx, offset nl
    mov ah, 9
    int 21h
    mov ax, 4C00h
    int 21h

; ---------- ROUTINES (camelCase) ----------

; printBin8: show [value] as 8 bits (4 + space + 4)
printBin8:
    ; high nibble
    mov al, [value]
    mov ah, al
    shr ah, 4
    and ah, 0Fh
    mov si, offset bin4Tbl
    mov bl, ah
    xor bh, bh
    shl bx, 2
    add si, bx
    call print4Chars

    ; space
    mov dl, ' '
    mov ah, 2
    int 21h

    ; low nibble
    mov al, [value]
    and al, 0Fh
    mov si, offset bin4Tbl
    mov bl, al
    xor bh, bh
    shl bx, 2
    add si, bx
    call print4Chars
    ret

; printOctal: prints [value] as octal (no leading spaces)
printOctal:
    push ax
    push bx
    push cx
    push dx

    xor ax, ax
    mov al, [value]       ; AX = 0..255

    cmp ax, 0
    jne poLoopPrep
    ; print single '0'
    mov dl, '0'
    mov ah, 2
    int 21h
    jmp poDone

poLoopPrep:
    xor cx, cx            ; digit count = 0
poLoop:
    xor dx, dx            ; DX:AX / BX
    mov bx, 8
    div bx                ; AX = AX/8, DX = remainder (0..7)
    add dl, '0'
    push dx               ; push ASCII digit in DL (in DX)
    inc  cx
    test ax, ax
    jnz  poLoop

; pop and print digits (MSD first)
poOut:
    pop  dx
    mov  ah, 2
    int  21h
    loop poOut

poDone:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; printHex2: show [value] as two hex digits (uppercase)
printHex2:
    ; high nibble
    mov al, [value]
    mov ah, al
    shr ah, 4
    and ah, 0Fh
    mov al, ah
    xor ah, ah
    mov si, offset hexTbl
    add si, ax
    lodsb
    mov dl, al
    mov ah, 2
    int 21h

    ; low nibble
    mov al, [value]
    and al, 0Fh
    xor ah, ah
    mov si, offset hexTbl
    add si, ax
    lodsb
    mov dl, al
    mov ah, 2
    int 21h
    ret

; print4Chars: prints 4 ASCII chars from DS:SI
print4Chars:
    mov cx, 4
p4Loop:
    lodsb
    mov dl, al
    mov ah, 2
    int 21h
    loop p4Loop
    ret
