org 100h

start:
    ; Set up data and video segments
    mov ax, cs
    mov ds, ax
    mov ax, 0B800h
    mov es, ax
    
    ; Initialize
    mov di, 0          ; Video memory position
    
    ; Calculate string length
    mov si, offset str
    call strlen
    mov [str_len], cl
    
    ; Display initial string
    mov si, offset str
    call display_string
    
    ; Rotate and display (length-1) times
    mov cl, [str_len]
    dec cl             ; Rotate length-1 times (back to original)
    mov ch, 0
    
rotate_loop:
    ; Move to next line (80 chars * 2 bytes = 160 per line)
    add di, 160
    
    ; Rotate string in place
    call rotate_right
    
    ; Display rotated string
    mov si, offset str
    call display_string
    
    loop rotate_loop
    
    hlt

; Calculate string length
; Input: SI = string address
; Output: CL = length
strlen:
    push ax
    push si
    mov cl, 0
strlen_loop:
    mov al, [si]
    cmp al, 0
    je strlen_done
    inc cl
    inc si
    jmp strlen_loop
strlen_done:
    pop si
    pop ax
    ret

; Rotate string right by one character
; Input: DS:SI = string address
rotate_right:
    push ax
    push bx
    push di
    push si
    
    mov di, si
    
    ; Find end of string using known length
    mov al, [str_len]
    mov ah, 0
    add di, ax
    dec di          ; Point to last character (before null terminator)
    
    mov al, [di]    ; Store last character
    
    ; Shift all characters right by one position
    shift_loop:
        cmp di, si
        je end_shift
        mov bl, [di-1]
        mov [di], bl
        dec di
        jmp shift_loop
    
    end_shift:
        ; Put last character at beginning
        mov [si], al
    
    pop si
    pop di
    pop bx
    pop ax
    ret

; Display string at current video position
; Input: DS:SI = string, ES:DI = video memory position
display_string:
    push ax
    push si
    push di
    
    mov ah, 0Fh  ; White text on black background
    
display_loop:
    mov al, [si]
    cmp al, 0
    je display_done
    mov es:[di], ax
    add di, 2
    inc si
    jmp display_loop
    
display_done:
    pop di
    pop si
    pop ax
    ret

; Data section
str db "Hello", 0
str_len db 0