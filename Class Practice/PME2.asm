; ==========================================
; Count vowels & consonants with individual vowel counts
; EMU8086 / DOS .COM
; ==========================================

org 100h
        jmp start

; ---------- DATA ----------
prompt      db 'Input a string [max. 20]: $'
inbuf       db 20          ; DOS 0Ah buffer: [0]=max, [1]=len, [2..]=data
inlen       db 0
intext      db 20 dup(0)

s_chars     db ' - chars inputted',0Dh,0Ah,'$'
s_a         db ' - a''s',0Dh,0Ah,'$'
s_e         db ' - e''s',0Dh,0Ah,'$'
s_i         db ' - i''s',0Dh,0Ah,'$'
s_o         db ' - o''s',0Dh,0Ah,'$'
s_u         db ' - u''s',0Dh,0Ah,'$'
s_vow       db ' - total vowels',0Dh,0Ah,'$'
s_con       db ' - total consonants',0Dh,0Ah,'$'
newline     db 0Dh,0Ah,'$'

cnt_len     dw 0
cnt_a       dw 0
cnt_e       dw 0
cnt_i       dw 0
cnt_o       dw 0
cnt_u       dw 0
cnt_v       dw 0
cnt_c       dw 0

; ---------- CODE ----------
start:
        push cs
        pop  ds

        ; Prompt user
        mov  dx, offset prompt
        mov  ah, 9
        int  21h

        ; Read input
        mov  dx, offset inbuf
        mov  ah, 0Ah
        int  21h

        ; Store input length (byte) in inlen
        mov  al, [inbuf+1]
        mov  inlen, al

        ; Copy input to intext
        mov  si, offset inbuf+2
        mov  di, offset intext
        mov  al, inlen
        mov  cl, al
        xor  ch, ch
        mov  cx, cx          ; CX = length for REP MOVSB
        rep movsb

        ; Clear counters
        xor  ax, ax
        mov  cnt_len, ax
        mov  cnt_a,   ax
        mov  cnt_e,   ax
        mov  cnt_i,   ax
        mov  cnt_o,   ax
        mov  cnt_u,   ax
        mov  cnt_v,   ax
        mov  cnt_c,   ax

        ; Set total length
        mov  al, inlen
        cbw
        mov  cnt_len, ax

        ; Scan characters
        mov  si, offset intext
        mov  al, inlen
        mov  cl, al
        xor  ch, ch          ; CX = inlen

scan_loop:
        cmp  cx, 0
        je   show_results

        lodsb                        ; AL = character

        ; convert to uppercase if lowercase
        cmp  al, 'a'
        jb   chk_letter
        cmp  al, 'z'
        ja   chk_letter
        sub  al, 20h                 ; 'a'-'z' -> 'A'-'Z'

chk_letter:
        cmp  al, 'A'
        jb   next_char
        cmp  al, 'Z'
        ja   next_char

        ; check vowels
        cmp  al, 'A'
        je   is_A
        cmp  al, 'E'
        je   is_E
        cmp  al, 'I'
        je   is_I
        cmp  al, 'O'
        je   is_O
        cmp  al, 'U'
        je   is_U

        ; consonant
        inc  word ptr cnt_c
        jmp  next_char

is_A:   inc  word ptr cnt_a
        inc  word ptr cnt_v
        jmp  next_char
is_E:   inc  word ptr cnt_e
        inc  word ptr cnt_v
        jmp  next_char
is_I:   inc  word ptr cnt_i
        inc  word ptr cnt_v
        jmp  next_char
is_O:   inc  word ptr cnt_o
        inc  word ptr cnt_v
        jmp  next_char
is_U:   inc  word ptr cnt_u
        inc  word ptr cnt_v

next_char:
        dec  cx
        jmp  scan_loop

; ---------- OUTPUT ----------
show_results:
        mov  dx, offset newline
        mov  ah, 9
        int  21h

        ; Print totals
        mov  ax, cnt_len
        call print_2d
        mov  ah, 9
        mov  dx, offset s_chars
        int  21h

        mov  ax, cnt_a
        call print_2d
        mov  ah, 9
        mov  dx, offset s_a
        int  21h

        mov  ax, cnt_e
        call print_2d
        mov  ah, 9
        mov  dx, offset s_e
        int  21h

        mov  ax, cnt_i
        call print_2d
        mov  ah, 9
        mov  dx, offset s_i
        int  21h

        mov  ax, cnt_o
        call print_2d
        mov  ah, 9
        mov  dx, offset s_o
        int  21h

        mov  ax, cnt_u
        call print_2d
        mov  ah, 9
        mov  dx, offset s_u
        int  21h

        mov  ax, cnt_v
        call print_2d
        mov  ah, 9
        mov  dx, offset s_vow
        int  21h

        mov  ax, cnt_c
        call print_2d
        mov  ah, 9
        mov  dx, offset s_con
        int  21h

        mov  ax, 4C00h
        int  21h

; ---------- ROUTINE ----------
; print_2d: print AX as decimal (0..99)
print_2d:
        cmp  ax, 99
        jbe  short p2_go
        mov  ax, 99
p2_go:
        xor  dx, dx
        mov  bx, 10
        div  bx
        ; tens
        push dx
        mov  dl, al
        add  dl, '0'
        mov  ah, 2
        int  21h
        ; ones
        pop  dx
        add dl, '0'
        mov ah, 2
        int  21h
        ret
