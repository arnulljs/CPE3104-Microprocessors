org 100h
jmp Start

Start:
    ; set DS = CS
    push cs
    pop  ds

    ; prompt
    mov  dx, offset Prompt
    mov  ah, 09h
    int  21h

    ; read number string
    mov  ah, 0Ah
    lea  dx, Buffer
    int  21h

    ; convert ASCII input to number
    lea  si, Buffer+2
    xor  ax, ax
    xor  bx, bx
    mov  cl, [Buffer+1]   ; number of chars entered
ConvLoop:
    cmp  cl, 0
    je   ConvDone
    mov  bl, [si]
    sub  bl, '0'
    mov  bh, 0
    mov  dx, ax
    mov  ax, 10
    mul  dx          ; AX = old*10
    add  ax, bx
    inc  si
    dec  cl
    jmp  ConvLoop
ConvDone:
    mov  [Amount], ax

    ; compute change
    mov  ax, [Amount]

    ; ---------------- P100
    mov  bx, 100
    xor  dx, dx
    div  bx
    push dx           ; remainder
    mov  cx, ax       ; count
    lea  dx, P100Msg
    call PrintMsgNum
    pop  ax

    ; ---------------- P50
    mov  bx, 50
    xor  dx, dx
    div  bx
    push dx
    mov  cx, ax
    lea  dx, P50Msg
    call PrintMsgNum
    pop  ax

    ; ---------------- P20
    mov  bx, 20
    xor  dx, dx
    div  bx
    push dx
    mov  cx, ax
    lea  dx, P20Msg
    call PrintMsgNum
    pop  ax

    ; ---------------- P5
    mov  bx, 5
    xor  dx, dx
    div  bx
    push dx
    mov  cx, ax
    lea  dx, P5Msg
    call PrintMsgNum
    pop  ax

    ; ---------------- P1
    mov  bx, 1
    xor  dx, dx
    div  bx
    mov  cx, ax
    lea  dx, P1Msg
    call PrintMsgNum

    ; exit
    mov  ax, 4C00h
    int  21h

; ----------------------------
; Helpers
; ----------------------------

; DX -> message string (ending with $)
; CX = number to print
PrintMsgNum:
    push ax
    push bx
    push cx
    push dx
    mov  ah, 09h
    int  21h
    mov  ax, cx
    call PrintNumber
    pop  dx
    pop  cx
    pop bx
    pop ax
    ret

; AX = number (0..65535)
PrintNumber:
    push ax
    push bx
    push cx
    push dx

    mov  bx, 10
    xor  cx, cx
PnLoop1:
    xor  dx, dx
    div  bx
    push dx
    inc  cx
    cmp  ax, 0
    jne  PnLoop1

PnLoop2:
    pop  dx
    add  dl, '0'
    mov  ah, 02h
    int  21h
    loop PnLoop2

    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret

; ----------------------------
; Data declarations
; ----------------------------
Prompt  db 'Enter amount (3 digits): $'
P100Msg db 13,10,'P100: $'
P50Msg  db 13,10,'P50 : $'
P20Msg  db 13,10,'P20 : $'
P5Msg   db 13,10,'P5  : $'
P1Msg   db 13,10,'P1  : $'

Amount  dw 0

Buffer  db 5       ; max chars to read
        db 0       ; actual length
        db 5 dup(0)
