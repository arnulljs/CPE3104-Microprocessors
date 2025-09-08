org 100h
start:
    
    mov ax, 0B800h              ; video buffer set
    mov es, ax
    mov di, 0000h
    
    mov ax,cs
    mov ds,ax
    
    mov al,  num                ; starting message number insert
    add al,  '0'
    mov [startMsg+14], al
    
    mov si, offset startMsg     ; disp msg
    call print 
    
    mov di, 156                 ; next line
    
    mov bl, num                 ; logical checking if  even or odd
    and bl, 1                   ; LSB AND 1
    cmp bl, 0                   ; cmp with 0, ZF=1 if odd, ZF=0 if even 
    je printEven
    
printOdd:
    mov si, offset oddMsg       ; odd message print
    call print
    jmp done
    
printEven:
    mov si, offset evenMsg      ; even message print
    call print

done:
    hlt

print:
    printLoop:                  ; looping thru each letter and displaying in video buffer
        mov al, [si]
        cmp al, 0
        je return
        
        mov es:[di], ax
        
        add di, 2
        inc si
        jmp printLoop
        
    return:
        ret
    
startMsg db "Stored value: ", "  ", 0
oddMsg db 13,10,"The number is odd.",0
evenMsg db 13,10,"The number is even.",0
num db 7