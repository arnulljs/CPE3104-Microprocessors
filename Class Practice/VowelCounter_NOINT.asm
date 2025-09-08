org 100h  

    start:
        mov ax,0B800h
        mov es, ax
        mov di, 0000h
        
        mov ax, cs
        mov ds, ax
        
        mov si, offset startMsg
        call  print
        
        mov si, offset stored
        call print
        
        mov di, 156
        
        mov si, offset stored
        mov bl, 0
        
    iter:
        mov al, [si]
        cmp al, 0
        je done
        
        cmp al, 'a'
        je isEqual
        cmp al, 'e'
        je isEqual
        cmp al, 'i'
        je isEqual
        cmp al, 'o'
        je isEqual
        cmp al, 'u'
        je isEqual
        jmp nextChar
    
    isEqual:
        inc bl
    
    nextChar:
        inc si
        jmp iter
        
   done:
        add bl, '0'
        mov [vowelMsg+13], bl
        mov di, 160
        mov si, offset vowelMsg
        call  print
      
    print:
        printLoop:           
            mov al, [si]
            cmp al, 0
            je return
            
            mov es:[di], ax
            
            add di, 2
            inc si
            jmp printLoop
            
        return:
            ret   
    
ret

stored db "power of the people",0
startMsg db "Stored string = ", 0
vowelMsg db "Vowel count:  ", 0


