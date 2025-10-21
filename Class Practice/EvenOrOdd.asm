org 100h


start:
    mov ah, 9   ; print
    mov dx, offset prompt
    int 21h
    
    mov ah, 1   ; read single digit
    int 21h
    sub al, '0' ; ascii to dec form?, ex. 8d = 38h, 0=30h, 38h-30h = 8h
    mov bl, al  ; copy? just to be safe i guess
    and al, 1   ; and operation. 1000 AND 0001 should output 0000 (really just checking LSB)
    cmp al, 0   ; if al is 0000, then ZF is 1. ex. 1000 AND 0001 = 0000, 0000 cmp 0000 is ZF=1
    je ifEven   ; if ZF = 1 then jump to even
    
ifOdd:
    mov ah, 9
    mov dx, offset oddMsg 
    int 21h
    jmp done
    
ifEven:
    mov ah, 9
    mov dx, offset evenMsg
    int 21h
    jmp done
    
done:
    mov ah, 4Ch
    int 21h    
    

prompt db "Enter a number: $"
evenMsg db 13,10,"The number is even!$"
oddMsg db 13,10,"The number is odd!$"

ret

; for all even cases 0,2,4,6,8
; this will be true: 0000, 0010, 0100, 0110, 1000
; any of those performed with AND will always result in 0000
; so if cmp with (000)0, it will return true on ZF always







































a