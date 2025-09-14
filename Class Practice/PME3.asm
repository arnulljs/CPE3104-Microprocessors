org 100h
jmp startProgram

startProgram:
    push cs
    pop  ds

getUserInput:
    mov dx, offset prompt
    mov ah, 09h
    int 21h

    mov dx, offset bufmax
    mov ah, 0Ah
    int 21h

    mov al, buflen
    cmp al, 1
    jb badInput
    cmp al, 20
    ja badInput
    test al, 1
    jz badInput

    mov [len], al
    push ds
    pop  es
    xor cx, cx
    mov cl, [len]
    mov si, offset bufdata
    mov di, offset str
    rep movsb
    jmp okInput

badInput:
    mov dx, offset badlen
    mov ah, 09h
    int 21h
    jmp getUserInput

okInput:
    mov ax, 0600h
    mov bh, [attr]
    xor cx, cx
    mov dx, 184Fh
    int 10h

    mov al, [len]
    xor ah, ah
    mov bl, 2
    div bl
    mov [midIdx], al

    xor bx, bx
    mov bl, [len]
    mov ax, 80
    sub ax, bx
    shr ax, 1
    mov [centerCol], al

    mov al, [centerCol]
    add al, [midIdx]
    mov [midCol], al

    mov al, [midIdx]
    mov [leftLen], al
    mov al, [len]
    sub al, [midIdx]
    dec al
    mov [rightLen], al

    mov al, [centerCol]
    mov [leftPos], al

    mov al, [midCol]
    inc al
    mov [rightPos], al

    mov al, 80
    sub al, [rightLen]
    mov [rMax], al

    mov al, 0
    mov [lGoal], al

    mov al, [centerCol]
    add al, [midIdx]
    inc al
    mov [rGoal], al

    mov al, 0
    mov [curRow], al
    mov [prevRow], al

downLoop:
    mov dh, [prevRow]
    call clearScreenRow

    mov dh, [curRow]
    mov dl, [centerCol]
    mov bl, [attr]
    xor ch, ch
    mov cl, [len]
    mov bp, offset str
    call drawAtPosition

    mov al, [curRow]
    cmp al, [bottomRow]
    je splitPhase
    mov [prevRow], al
    mov al, [curRow]
    inc al
    mov [curRow], al
    jmp downLoop

splitPhase:
splitLoop:
    mov dh, [bottomRow]
    call clearScreenRow

    mov dh, [bottomRow]
    mov dl, [leftPos]
    mov bl, [attr]
    xor ch, ch
    mov cl, [leftLen]
    cmp cl, 0
    je drawMidTry
    mov bp, offset str
    call drawAtPosition

drawMidTry:
    mov al, [rightPos]
    cmp al, [rMax]
    je skipMid
    mov dh, [bottomRow]
    mov dl, [midCol]
    mov bl, [attr]
    mov si, offset str
    mov al, [midIdx]
    xor ah, ah
    add si, ax
    mov bp, si
    mov cx, 1
    call drawAtPosition
skipMid:

    mov dh, [bottomRow]
    mov dl, [rightPos]
    mov bl, [attr]
    mov si, offset str
    mov al, [midIdx]
    xor ah, ah
    add si, ax
    inc si
    mov bp, si
    xor ch, ch
    mov cl, [rightLen]
    cmp cl, 0
    je afterDrawRight
    call drawAtPosition
afterDrawRight:

    mov al, [leftPos]
    cmp al, [lGoal]
    je noLeftMove
    mov al, [leftPos]
    dec al
    mov [leftPos], al
noLeftMove:

    mov al, [rightPos]
    cmp al, [rMax]
    je noRightMove
    mov al, [rightPos]
    inc al
    mov [rightPos], al
noRightMove:

    mov al, [leftPos]
    cmp al, [lGoal]
    jne splitLoop
    mov al, [rightPos]
    cmp al, [rMax]
    jne splitLoop

    mov dh, [bottomRow]
    call clearScreenRow
    mov al, [bottomRow]
    mov [prevRow], al
    mov [curRow],  al
    jmp riseLoop

riseLoop:
    mov dh, [prevRow]
    call clearScreenRow

    mov dh, [curRow]
    mov dl, [leftPos]
    mov bl, [attr]
    xor ch, ch
    mov cl, [leftLen]
    cmp cl, 0
    je riseDrawMid
    mov bp, offset str
    call drawAtPosition
riseDrawMid:
    mov dh, [curRow]
    mov dl, [midCol]
    mov bl, [attr]
    mov si, offset str
    mov al, [midIdx]
    xor ah, ah
    add si, ax
    mov bp, si
    mov cx, 1
    call drawAtPosition
    mov dh, [curRow]
    mov dl, [rightPos]
    mov bl, [attr]
    mov si, offset str
    mov al, [midIdx]
    xor ah, ah
    add si, ax
    inc si
    mov bp, si
    xor ch, ch
    mov cl, [rightLen]
    cmp cl, 0
    je riseAfterDraw
    call drawAtPosition
riseAfterDraw:

    mov al, [curRow]
    cmp al, 0
    je mergePhase
    mov [prevRow], al
    mov al, [curRow]
    dec al
    mov [curRow], al
    jmp riseLoop

mergePhase:
mergeLoop:
    mov dh, 0
    call clearScreenRow

    mov dh, 0
    mov dl, [leftPos]
    mov bl, [attr]
    xor ch, ch
    mov cl, [leftLen]
    cmp cl, 0
    je mergeDrawMid
    mov bp, offset str
    call drawAtPosition
mergeDrawMid:
    mov dh, 0
    mov dl, [midCol]
    mov bl, [attr]
    mov si, offset str
    mov al, [midIdx]
    xor ah, ah
    add si, ax
    mov bp, si
    mov cx, 1
    call drawAtPosition
    mov dh, 0
    mov dl, [rightPos]
    mov bl, [attr]
    mov si, offset str
    mov al, [midIdx]
    xor ah, ah
    add si, ax
    inc si
    mov bp, si
    xor ch, ch
    mov cl, [rightLen]
    cmp cl, 0
    je afterMergeDraw
    call drawAtPosition
afterMergeDraw:

    mov al, [leftPos]
    cmp al, [centerCol]
    je noLeftIn
    mov al, [leftPos]
    inc al
    mov [leftPos], al
noLeftIn:

    mov al, [rightPos]
    cmp al, [rGoal]
    je noRightIn
    mov al, [rightPos]
    dec al
    mov [rightPos], al
noRightIn:

    mov al, [leftPos]
    cmp al, [centerCol]
    jne mergeLoop
    mov al, [rightPos]
    cmp al, [rGoal]
    jne mergeLoop

    mov dh, 0
    call clearScreenRow
    mov dh, 0
    mov dl, [centerCol]
    mov bl, [attr]
    xor ch, ch
    mov cl, [len]
    mov bp, offset str
    call drawAtPosition

    mov ax, 4C00h
    int 21h

; ---------- subroutines ----------
clearScreenRow:
    push ax
    push bx
    push cx
    push dx
    push bp
    push ds
    pop  es
    mov dl, 0
    mov ax, 1301h
    mov bh, 0
    mov bl, [attr]
    mov cx, 80
    lea bp, space80
    int 10h
    pop  bp
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret

drawAtPosition:
    push ax
    push bx
    push cx
    push dx
    push bp
    push ds
    pop  es
    mov ax, 1301h
    mov bh, 0
    int 10h
    pop  bp
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
       
bufmax      db 20
buflen      db 0
bufdata     db 20 dup(0)

prompt      db 'Enter ODD-length text (max 20): $'
badlen      db 0Dh,0Ah,'Length must be odd',0Dh,0Ah,'$'

space80     db 80 dup(' ')
attr        db 0Eh

str         db 20 dup(0)
len         db 0
midIdx      db 0
centerCol   db 0
midCol      db 0

leftLen     db 0
rightLen    db 0

leftPos     db 0
rightPos    db 0
lGoal       db 0
rGoal       db 0
rMax        db 0

curRow      db 0
prevRow     db 0
bottomRow   db 24