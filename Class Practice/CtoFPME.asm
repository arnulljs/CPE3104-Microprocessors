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
    call parseInt
    jc   badInput

    ; AX = Celsius
    ; Fahrenheit = C * 9 / 5 + 32  (signed, trunc toward 0)
    cwd                     ; sign-extend into DX
    mov bx, 9
    imul bx                 ; DX:AX = C*9
    mov bx, 5
    idiv bx                 ; AX = C*9/5
    add ax, 32              ; add 32 for Fahrenheit

    ; print label + result (preserve AX across DOS 09h)
    push ax
    mov dx, offset resLabel
    mov ah, 09h
    int 21h
    pop  ax
    call printInt

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

parseInt:
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
piSkipLead:
    cmp byte ptr [si], ' '
    jne piSign
    inc si
    loop piSkipLead
    jmp piErr                ; all spaces

    ; optional sign
piSign:
    xor dl, dl               ; DL=0 positive, 1 negative
    jcxz piErr
    cmp byte ptr [si], '+'
    jne piChkMinus
    inc si
    dec cx
    jmp piNeedDigit

piChkMinus:
    cmp byte ptr [si], '-'
    jne piNeedDigit
    mov dl, 1
    inc si
    dec cx

    ; must start with a digit
piNeedDigit:
    jcxz piErr
    mov bl, [si]
    cmp bl, '0'
    jb  piErr
    cmp bl, '9'
    ja  piErr

    xor ax, ax               ; AX=result

    ; read digits
piDigits:
    jcxz piAfterDigits
    mov bl, [si]
    cmp bl, '0'
    jb  piAfterDigits
    cmp bl, '9'
    ja  piAfterDigits

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
    jmp piDigits

    ; skip trailing spaces
piAfterDigits:
    jcxz piApplySign
piTrimTrail:
    cmp byte ptr [si], ' '
    jne piCheckLeftover
    inc si
    loop piTrimTrail

piCheckLeftover:
    jcxz piApplySign
    jmp piErr               ; leftover non-space -> error

    ; apply sign
piApplySign:
    test dl, dl
    jz   piOk
    neg  ax

piOk:
    clc
    jmp piExit

piErr:
    stc

piExit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

printInt:
    push bx
    push cx
    push dx

    ; handle sign
    cmp ax, 0
    jge piAbs
    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax

piAbs:
    ; zero special-case
    cmp ax, 0
    jne piConv
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp piDone

    ; push digits
piConv:
    xor cx, cx
    mov bx, 10
piDiv:
    xor dx, dx
    div bx              ; AX /=10, DX=remainder
    push dx
    inc cx
    test ax, ax
    jnz piDiv

    ; pop digits to print
piOut:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop piOut

piDone:
    pop dx
    pop cx
    pop bx
    ret

; -----------------------------
; DATA DECLARATIONS
; -----------------------------

prompt      db 'Enter Celsius (integer): $'
errMsg      db 13,10,'Invalid input. Try again.',13,10,'$'
resLabel    db 13,10,'Fahrenheit: $'
doneMsg     db 13,10,13,10,'Press any key to exit...$'

; DOS 0Ah input buffer (keyboard line input)
inMax       db 16          ; max chars user may type
inLen       db 0           ; actual chars read (count)
inData      db 16 dup(0)   ; typed data (not zero-terminated)
