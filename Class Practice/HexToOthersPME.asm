; ==========================================
; HEX (1-2 digits) -> Binary (two nibbles), Octal, Decimal
; CamelCase function names
; ==========================================

org 100h
    jmp start

; ---------- DATA ----------
prompt      db 'Enter hex (00-FF): $'
nl          db 0Dh,0Ah,'$'
msgBin      db 0Dh,0Ah,'Binary : $'
msgOct      db 0Dh,0Ah,'Octal  : $'
msgDec      db 0Dh,0Ah,'Decimal: $'

value       db 0        ; parsed byte 0..255
digits      db 0        ; 1 or 2 digits entered

; lookup table: 16 nibbles ? 4 ASCII chars each
bin4Tbl    db '0000','0001','0010','0011'
           db '0100','0101','0110','0111'
           db '1000','1001','1010','1011'
           db '1100','1101','1110','1111'

; ---------- CODE ----------
start:
    push cs
    pop ds

    ; prompt
    mov dx, offset prompt
    mov ah, 9
    int 21h

    ; reset
    mov [digits], 0
    mov [value],  0

    ; ---- read first char ----
    mov ah, 1
    int 21h
    cmp al, 0Dh
    je doneInput            ; Enter immediately ? value=0
    call hexToNibble
    jnc doneInput           ; not hex ? quit with value=0
    mov bl, al               ; first nibble (0..15)
    mov [digits], 1

    ; ---- read second char (optional) ----
    mov ah, 1
    int 21h
    cmp al, 0Dh
    je oneDigit
    call hexToNibble
    jnc oneDigit
    ; two digits: value = (first<<4) | second
    mov bh, bl
    shl bh, 4
    or  bh, al
    mov [value], bh
    mov [digits], 2
    jmp parsed

oneDigit:
    ; one digit -> low nibble only
    mov [value], bl

parsed:
doneInput:
    ; newline
    mov dx, offset nl
    mov ah, 9
    int 21h

    ; ----- Binary -----
    mov dx, offset msgBin
    mov ah, 9
    int 21h
    call printBinaryNibbles

    ; ----- Octal -----
    mov dx, offset msgOct
    mov ah, 9
    int 21h
    call printOctalValue

    ; ----- Decimal -----
    mov dx, offset msgDec
    mov ah, 9
    int 21h
    call printDecimalValue

    ; newline + exit
    mov dx, offset nl
    mov ah, 9
    int 21h
    mov ax, 4C00h
    int 21h

; ---------- ROUTINES ----------

hexToNibble:
    cmp al,'0'
    jb  hnBad
    cmp al,'9'
    jbe hn09
    cmp al,'A'
    jb  hnACheck
    cmp al,'F'
    jbe hnAF
    cmp al,'a'
    jb  hnBad
    cmp al,'f'
    ja  hnBad
    sub al,87         ; 'a'(97) -> 10
    stc
    ret
hnAF:
    sub al,55         ; 'A'(65) -> 10
    stc
    ret
hn09:
    sub al,'0'
    stc
    ret
hnACheck:
    cmp al,'a'
    jb  hnBad
    cmp al,'f'
    ja  hnBad
    sub al,87
    stc
    ret
hnBad:
    clc
    ret

printBinaryNibbles:
    mov al,[digits]
    cmp al,1
    jne printTwoDigitsBinary

    ; ---- one digit ----
    mov si, offset bin4Tbl
    call print4Chars
    ; space
    mov dl,' '
    mov ah,2
    int 21h
    ; low nibble
    mov al,[value]
    and al,0Fh
    xor ah,ah
    mov bx,ax
    shl bx,2
    mov si, offset bin4Tbl
    add si,bx
    call print4Chars
    ret

printTwoDigitsBinary:
    ; high nibble
    mov al,[value]
    xor ah,ah
    shr al,4
    mov bx,ax
    shl bx,2
    mov si, offset bin4Tbl
    add si,bx
    call print4Chars
    ; space
    mov dl,' '
    mov ah,2
    int 21h
    ; low nibble
    mov al,[value]
    and al,0Fh
    xor ah,ah
    mov bx,ax
    shl bx,2
    mov si, offset bin4Tbl
    add si,bx
    call print4Chars
    ret

print4Chars:
    mov cx,4
p4Loop:
    lodsb
    mov dl,al
    mov ah,2
    int 21h
    loop p4Loop
    ret

printOctalValue:
    push ax
    push bx
    push cx
    push dx

    xor  ax, ax
    mov  al, [value]         ; AX = value 0..255
    cmp  ax, 0
    jne  poLoopPrep
    mov  dl, '0'
    mov  ah, 2
    int  21h
    jmp  poDone

poLoopPrep:
    xor  cx, cx
poLoop:
    xor  dx, dx
    mov  bx, 8
    div  bx                  ; AX=quotient, DX=remainder (0..7)
    add  dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz  poLoop

poOut:
    pop dx
    mov  ah, 2
    int 21h
    dec cx
    jnz poOut

poDone:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

printDecimalValue:
    push ax
    push bx
    push cx
    push dx

    xor  ax, ax
    mov  al, [value]
    cmp  ax, 0
    jne pdConvert
    mov  dl, '0'
    mov  ah, 2
    int 21h
    jmp pdDone

pdConvert:
    xor  cx, cx
    mov  bx,10
pdDiv:
    xor  dx, dx
    div  bx
    add  dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz pdDiv

pdOut:
    pop dx
    mov ah,2
    int 21h
    dec cx
    jnz pdOut

pdDone:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
