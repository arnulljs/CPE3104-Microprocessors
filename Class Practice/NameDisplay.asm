org 100h

start:
    mov ax, 0B800h       ; set video memory segment
    mov ds, ax
    mov si, 07C2h         ; offset

    call print_name

    ret

print_name:
    mov al, 'A'
    mov [si], al
    mov ah, 1Eh
    mov [si+1], ah

    mov al, 'r'
    mov [si+2], al
    mov [si+3], ah

    mov al, 'n'
    mov [si+4], al
    mov [si+5], ah

    mov al, 'o'
    mov [si+6], al
    mov [si+7], ah

    mov al, 'l'
    mov [si+8], al
    mov [si+9], ah

    mov al, 'd'
    mov [si+10], al
    mov [si+11], ah

    mov al, ' '
    mov [si+12], al
    mov [si+13], ah

    mov al, 'N'
    mov [si+14], al
    mov [si+15], ah

    mov al, 'a'
    mov [si+16], al
    mov [si+17], ah

    mov al, 'j'
    mov [si+18], al
    mov [si+19], ah

    mov al, 'e'
    mov [si+20], al
    mov [si+21], ah

    mov al, 'r'
    mov [si+22], al
    mov [si+23], ah

    mov al, 'a'
    mov [si+24], al
    mov [si+25], ah

    ret