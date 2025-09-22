; you may customize this and other start-up templates;
; the location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

    lea dx, msgPrompt
    mov ah, 9
    int 21h

    call getInput
    call clearScreen

    xor cx, cx
    mov dh, 24

display:
    mov al, 1
    mov bl, 0Eh
    mov cl, input[1]

    mov bh, input[1]
    cmp bh, 5
    je lenCase5
    cmp bh, 7
    je lenCase7

    mov bh, 0
    mov dl, 41
    sub dl, input[1]

start:
    lea bp, input+2
    mov ah, 13h
    int 10h

    cmp dh, 11
    je atTop

    lea bp, blank
    mov ah, 13h
    int 10h

    dec dh
    jmp display

ret

atTop proc
    mov ax, 0b800h
    mov es, ax

    xor bx, bx
    xor dx, dx

    mov bl, input[1]
    cmp bx, 5
    je move2Outwards
    cmp bx, 7
    je move3Outwards

    mov cx, 38
    mov di, 76
    mov si, 80

    mov dl, input[4]
    mov dh, 00h
    mov es:[si], dx
    add si, 2
    mov dl, input[4]
    mov dh, 0Eh
    mov es:[si], dx

    call move1Outwards

    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown

    mov cx, 38
    mov di, 3840
    mov si, 3998

    mov dl, input[4]
    mov dh, 00h
    mov es:[si], dx
    sub si, 2
    mov dl, input[4]
    mov dh, 0Eh
    mov es:[si], dx

    call move1Inwards

    call moveUp
    call moveUp
    call moveUp
    call moveUp

    jmp exitProg

atTop endp

lenCase5:
    mov bh, 0
    mov dl, 43
    sub dl, input[1]
    jmp start

lenCase7:
    mov bh, 0
    mov dl, 44
    sub dl, input[1]
    jmp start

move1Outwards:
    cmp cx, 0
    je done1
    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    sub di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    mov dl, input[4]
    mov dh, 00h
    mov es:[si], dx
    add si, 2
    mov dl, input[4]
    mov dh, 0Eh
    mov es:[si], dx
    loop move1Outwards
done1:
    ret

move2Outwards:
    mov cx, 37
    mov di, 76
    mov si, 78
    push di
    push si
    ; 72 74 76 78 80

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx

    sub di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    sub si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx

    push di
    push si

move2:
    cmp cx, 0
    je done2

    pop si
    pop di

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx

    sub di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    sub si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx

    push di
    push si

    mov di, len5L4Holder1[0]
    mov si, len5L5Holder1[0]

    mov dl, input[5]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[6]
    mov bh, 00h
    mov es:[si], bx

    add di, 2
    mov dl, input[5]
    mov dh, 0Eh
    mov es:[di], dx
    add si, 2
    mov bl, input[6]
    mov bh, 07h
    mov es:[si], bx

    mov len5L4Holder1[0], di
    mov len5L5Holder1[0], si

    loop move2
done2:
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown

    jmp move2Inwards

move3Outwards:
    mov cx, 36
    mov di, 74
    mov si, 76
    mov bp, 78
    ; 72 76 78 80 82 84 86

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx
    mov al, input[4]
    mov ah, 00h
    mov es:[bp], ax

    sub di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    sub si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx
    sub bp, 2
    mov bl, input[4]
    mov bh, 07h
    mov es:[bp], bx

    push di
    push si
    push bp

move3:
    cmp cx, 0
    je done4

    pop bp
    pop si
    pop di

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx
    mov al, input[4]
    mov ah, 00h
    mov es:[bp], ax

    sub di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    sub si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx
    sub bp, 2
    mov al, input[4]
    mov ah, 07h
    mov es:[bp], ax

    push di
    push si
    push bp

    mov di, len7L5Holder1
    mov si, len7L6Holder1
    mov bp, len7L7Holder1

    mov dl, input[6]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[7]
    mov bh, 00h
    mov es:[si], bx
    mov al, input[8]
    mov ah, 00h
    mov es:[bp], bx

    add di, 2
    mov dl, input[6]
    mov dh, 0Eh
    mov es:[di], dx
    add si, 2
    mov bl, input[7]
    mov bh, 07h
    mov es:[si], bx
    add bp, 2
    mov al, input[8]
    mov ah, 07h
    mov es:[bp], ax

    mov len7L5Holder1, di
    mov len7L6Holder1, si
    mov len7L7Holder1, bp

    loop move3
done4:
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown
    call moveDown

    jmp move3Inwards

moveDown:
    mov al, 1
    mov bh, 00h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov ah, 07h
    int 10h

    mov al, 1
    mov bh, 00h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov ah, 07h
    int 10h

    mov al, 1
    mov bh, 00h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov ah, 07h
    int 10h
    ret

move1Inwards:
    cmp cx, 0
    je done3
    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    add di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    mov dl, input[4]
    mov dh, 00h
    mov es:[si], dx
    sub si, 2
    mov dl, input[4]
    mov dh, 0Eh
    mov es:[si], dx
    loop move1Inwards
done3:
    ret

move2Inwards:
    mov cx, 37
    mov di, 3840
    mov si, 3842
    push di
    push si

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx

    add di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    add si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx

    push di
    push si

move21:
    cmp cx, 0
    je done5

    pop si
    pop di

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx

    add di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    add si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx

    push di
    push si

    mov di, len5L4Holder2[0]
    mov si, len5L5Holder2[0]

    mov dl, input[5]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[6]
    mov bh, 00h
    mov es:[si], bx

    sub di, 2
    mov dl, input[5]
    mov dh, 0Eh
    mov es:[di], dx
    sub si, 2
    mov bl, input[6]
    mov bh, 07h
    mov es:[si], bx

    mov len5L4Holder2[0], di
    mov len5L5Holder2[0], si

    loop move21
done5:
    call moveUp
    call moveUp
    call moveUp
    call moveUp

    jmp exitProg

move3Inwards:
    mov cx, 36
    mov di, 3840
    mov si, 3842
    mov bp, 3844
    push di
    push si
    push bp

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx
    mov al, input[4]
    mov ah, 00h
    mov es:[bp], ax

    add di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    add si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx
    add bp, 2
    mov bl, input[4]
    mov bh, 07h
    mov es:[bp], bx

    push di
    push si
    push bp

move31:
    cmp cx, 0
    je done6

    pop bp
    pop si
    pop di

    mov dl, input[2]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[3]
    mov bh, 00h
    mov es:[si], bx
    mov al, input[4]
    mov ah, 00h
    mov es:[bp], ax

    add di, 2
    mov dl, input[2]
    mov dh, 0Eh
    mov es:[di], dx
    add si, 2
    mov bl, input[3]
    mov bh, 07h
    mov es:[si], bx
    add bp, 2
    mov al, input[4]
    mov ah, 07h
    mov es:[bp], ax

    push di
    push si
    push bp

    mov di, len7L5Holder2
    mov si, len7L6Holder2
    mov bp, len7L7Holder2

    mov dl, input[6]
    mov dh, 00h
    mov es:[di], dx
    mov bl, input[7]
    mov bh, 00h
    mov es:[si], bx
    mov al, input[8]
    mov ah, 00h
    mov es:[bp], bx

    sub di, 2
    mov dl, input[6]
    mov dh, 0Eh
    mov es:[di], dx
    sub si, 2
    mov bl, input[7]
    mov bh, 07h
    mov es:[si], bx
    sub bp, 2
    mov al, input[8]
    mov ah, 07h
    mov es:[bp], ax

    mov len7L5Holder2, di
    mov len7L6Holder2, si
    mov len7L7Holder2, bp

    loop move31
done6:
    call moveUp
    call moveUp
    call moveUp
    call moveUp

    jmp exitProg

moveUp:
    mov al, 1
    mov bh, 00h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov ah, 06h
    int 10h

    mov al, 1
    mov bh, 00h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov ah, 06h
    int 10h

    mov al, 1
    mov bh, 00h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov ah, 06h
    int 10h
    ret

setCursorPos:
    mov dl, 40
    sub dl, input[1]
    add dl, 1
    mov ah, 2
    int 10h
    ret

getInput:
    lea dx, input
    mov ah, 0Ah
    int 21h
    ret

clearScreen:
    mov al, 03h
    mov ah, 0
    int 10h
    ret

newLine:
    mov dx, 13
    mov ah, 2
    int 21h
    mov dx, 10
    mov ah, 2
    int 21h
    ret

exitProg:
    mov ah, 4Ch
    int 21h

; ---------- data ----------
msgPrompt db 'Enter an odd string: $'
input db 20, ?, 20 dup(?)
blank db '                    '

len5L4Holder1 dw 82
len5L5Holder1 dw 84
len5L4Holder2 dw 3996
len5L5Holder2 dw 3998

len7L5Holder1 dw 82
len7L6Holder1 dw 84
len7L7Holder1 dw 86
len7L5Holder2 dw 3994
len7L6Holder2 dw 3996
len7L7Holder2 dw 3998
