org 100h

jmp skip

;start:
;    mov ah, 9
;    mov dx, offset prompt
;    int 21h
;    
;    mov ah, 0ah
;    mov dx, offset input
;    int 21h
;    mov [si], dx
;    
;    mov si, offset input + 2
;    mov cl, 0
;    mov ch, [input+1]
    
;nexta:
;    cmp ch, 0
;    je done
;    mov al, [si]
;    dec ch

;check_aa:
;    mov al, [si]
;    cmp al, 'a'
;    jne check_e
;    inc cl
;    je next_vowel

;check_ea:
;    mov al, [si]
;    cmp al, 'e'
;    jne check_i
;    inc cl
;    je next_vowel 

;check_ia:
;    mov al, [si]
;    cmp al, 'i'
;    jne check_o
;    inc cl
;    je next_vowel
    
;check_oa:
;    mov al, [si]
;    cmp al, 'o'
;    jne check_u
;    inc cl
;    je next_vowel
    
;check_ua:
;    mov al, [si]
;    cmp al, 'u'
;    jne next_vowel
;    inc cl 
;    jmp next_vowel 
    
;next_vowela:
;    inc si
;    jmp next    
    
;donea:
;    mov al, cl
;    add al, '0'
;    mov [msg+12], al
    
;    mov ah, 9
;    mov dx, offset msg
;    int 21h
    
;    mov ah, 4Ch
;    int 21h
         
      
skip:

    start:
       mov ah, 9
       mov dx, offset prompt
       int 21h
        
       mov ah, 0ah
       mov dx, offset input
       int 21h
       mov [si], dx
        
       mov si, offset input + 2
       mov cl, 0
       mov ch, [input + 1]
    
    next:
       cmp ch, 0
       je done
       mov al, [si] 
        
       cmp al, 'a'
       je equal
        
       cmp al, 'e'
       je equal
        
       cmp al, 'i'
       je equal
        
       cmp al, 'o'
       je equal
        
       cmp al, 'u'
       je equal
    
    not_equal:
       inc si
       dec ch
       jmp next
    
    equal:
       inc cl
       inc si
       dec ch
       jmp next
       
    
    done:
       mov al, cl
       add al, '0'
       mov [msg+12], al
        
       mov ah, 9
       mov dx, offset msg
       int 21h
        
       mov ah, 4Ch
       int 21h
        
prompt db "Input a string: $" 
msg db 13,10,"There are ", ' ', 0, "vowels in the word!$"
input db 30
      db ?
      db 30 dup(?) 