org 100h
jmp start

start:
    ; DS = CS (so our data prints correctly in .COM)
    push cs
    pop  ds

readAgain:
    ; show prompt
    mov dx, offset prompt
    mov ah, 09h
    int 21h

    ; read line into DOS 0Ah buffer
    mov dx, offset inMax
    mov ah, 0Ah
    int 21h

    ; parse signed integer from buffer -> AX, CF=0 if ok
    call parseInteger
    jc   badInput

    ; AX = Fahrenheit
    ; Celsius = (F - 32) * 5 / 9  (signed, trunc toward 0)
    sub ax, 32
    cwd                     ; sign-extend into DX
    mov bx, 5
    imul bx                 ; DX:AX = (F-32)*5
    mov bx, 9
    idiv bx                 ; AX = Celsius

    ; print label + result (preserve AX across DOS 09h)
    push ax
    mov dx, offset resLabel
    mov ah, 09h
    int 21h
    pop  ax
    call printInteger

    ;; finish message and exit
    mov ax, 4C00h
    int 21h

badInput:
    mov dx, offset errMsg
    mov ah, 09h
    int 21h
    jmp readAgain

; -----------------------------
; PROCEDURES
; -----------------------------

parseInteger:
    push bx
    push cx
    push dx
    push si
    push di

    lea si, inData           ; SI -> first typed char
    xor cx, cx
    mov cl, [inLen]          ; CX = chars typed
    jcxz piErr               ; empty -> error

    ; skip leading spaces
parseSkipLead:
    cmp byte ptr [si], ' '
    jne parseSign
    inc si
    loop parseSkipLead
    jmp piErr                ; all spaces

    ; optional sign
parseSign:
    xor dl, dl               ; DL=0 positive, 1 negative
    jcxz piErr
    cmp byte ptr [si], '+'
    jne parseChkMinus
    inc si
    dec cx
    jmp parseNeedDigit

parseChkMinus:
    cmp byte ptr [si], '-'
    jne parseNeedDigit
    mov dl, 1
    inc si
    dec cx

    ; must start with a digit
parseNeedDigit:
    jcxz piErr
    mov bl, [si]
    cmp bl, '0'
    jb  piErr
    cmp bl, '9'
    ja  piErr

    xor ax, ax               ; AX=result

    ; read digits
parseDigits:
    jcxz parseAfterDigits
    mov bl, [si]
    cmp bl, '0'
    jb  parseAfterDigits
    cmp bl, '9'
    ja  parseAfterDigits

    ; AX = AX*10 + digit
    mov di, ax
    shl di, 1                ; *2
    shl di, 1                ; *4
    shl di, 1                ; *8
    shl ax, 1                ; *2
    add ax, di               ; *10
    sub bl, '0'
    xor bh, bh
    add ax, bx

    inc si
    dec cx
    jmp parseDigits

    ; skip trailing spaces
parseAfterDigits:
    jcxz parseApplySign
parseTrimTrail:
    cmp byte ptr [si], ' '
    jne parseCheckLeftover
    inc si
    loop parseTrimTrail

parseCheckLeftover:
    jcxz parseApplySign
    jmp piErr               ; leftover non-space -> error

    ; apply sign
parseApplySign:
    test dl, dl
    jz   parseOk
    neg  ax

parseOk:
    clc
    jmp parseExit

piErr:
    stc

parseExit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

printInteger:
    push bx
    push cx
    push dx

    ; handle sign
    cmp ax, 0
    jge printAbs
    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax

printAbs:
    ; zero special-case
    cmp ax, 0
    jne printConv
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp printDone

    ; push digits
printConv:
    xor cx, cx
    mov bx, 10
printDiv:
    xor dx, dx
    div bx              ; AX /=10, DX=remainder
    push dx
    inc cx
    test ax, ax
    jnz printDiv

    ; pop digits to print
printOut:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop printOut

printDone:
    pop dx
    pop cx
    pop bx
    ret

; -----------------------------
; DATA DECLARATIONS
; -----------------------------

prompt      db 'Enter Fahrenheit (integer): $'
errMsg      db 13,10,'Invalid input. Try again.',13,10,'$'
resLabel    db 13,10,'Celsius: $'
doneMsg     db 13,10,13,10,'Press any key to exit...$'

; DOS 0Ah input buffer (keyboard line input)
inMax       db 16          ; max chars user may type
inLen       db 0           ; actual chars read (count)
inData      db 16 dup(0)   ; typed data (not zero-terminated)
