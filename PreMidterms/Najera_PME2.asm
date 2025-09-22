org 100h

start:
    mov dx, offset INPUT_A_MSG
    mov ah, 09h
    int 21h
    
    mov  ah, 0Ah
    lea  dx, INPUT_A
    int  21h

    sub [INPUT_A], '0'
    
    mov dx, offset INPUT_B_MSG
    mov ah, 09h
    int 21h
    
    mov  ah, 0Ah
    lea  dx, INPUT_B
    int  21h

    ;lea  si, INPUT_B+2
;    xor  ax, ax
;    xor  bx, bx
;    mov  cl, [INPUT_B+1]
    
    mov dx, offset INPUT_C_MSG
    mov ah, 09h
    int 21h
    
    mov  ah, 0Ah
    lea  dx, INPUT_C
    int  21h

    ;lea  si, INPUT_C+2
;    xor  ax, ax
;    xor  bx, bx
;    mov  cl, [INPUT_C+1]
    
    mov dx, offset INPUT_D_MSG
    mov ah, 09h
    int 21h
    
    mov  ah, 0Ah
    lea  dx, INPUT_D
    int  21h

    ;lea  si, INPUT_D+2
;    xor  ax, ax
;    xor  bx, bx
;    mov  cl, [INPUT_D+1] 

    sub [INPUT_B], '0'
    sub [INPUT_C], '0'
    sub [INPUT_D], '0'
    
    mov dx, offset SEPARATOR
    mov ah, 09h
    int 21h
    
    mov dx, offset SHOW_A
    mov ah, 09h
    int 21h
    
    mov cx, offset INPUT_A
    call PrintMsgNum
    
    mov cx, offset INPUT_B
    call PrintMsgNum
    
    mov cx, offset INPUT_C
    call PrintMsgNum
    
    mov cx, offset INPUT_D
    call PrintMsgNum
    

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
    
    mov  bx, 100
    xor  dx, dx
    div  bx
    push dx           
    mov  cx, ax       
    lea  dx, SHOW_A
    call PrintMsgNum
    pop  ax 
    
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
    
ret
  
    
    
INPUT_A db 3
        db 0
        db 3 dup(0)
INPUT_B db 3
        db 0
        db 3 dup(0)
INPUT_C db 3
        db 0
        db 3 dup(0)
INPUT_D db 3
        db 0
        db 3 dup(0)
INPUT_A_MSG db "Input A: $"
INPUT_B_MSG db 13,10,"Input B: $"
INPUT_C_MSG db 13,10,"Input C: $"
INPUT_D_MSG db 13,10,"Input D: $"
SEPARATOR db 13,10,"===========================$"
SHOW_A db 13,10," = $"
SHOW_B db 13,10," = $"
SHOW_C db 13,10," = $"
SHOW_D db 13,10," = $"
EQUAL db 13,10,"X = $"
MINUS db " - $"
TIMES db " x $"
DIVID db " / $"
