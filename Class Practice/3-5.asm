org 100h

.code
START:
    MOV AX, 0000h
    INT 33h
    CMP AX, 0
    JE NO_MOUSE
    MOV AX, 0001h       ; show mouse cursor
    INT 33h

NO_MOUSE:
    CALL DISPLAY_MENU

MAIN_LOOP:
    MOV AH, 01h         ; kb input check
    INT 16h
    JZ CHECK_MOUSE
    
    MOV AH, 00h         ; process kb input
    INT 16h
    
    CMP AL, '1'
    JE HORZSTR
    CMP AL, '2'
    JE VERTSTR
    CMP AH, 3Bh
    JE CHECKERED
    CMP AL, 'q'
    JE CLOSE 
    CMP AL, 'Q'
    JE CLOSE
    JMP ERR

CHECK_MOUSE:
    MOV AX, 0003h
    INT 33h
    CMP BX, 1           ; mouse 1 clicked
    JNE MAIN_LOOP
    
    SHR CX, 3           ; pixel to text coordinates
    SHR DX, 3     
    
    CMP DX, 6
    JB MAIN_LOOP
    CMP DX, 9
    JA MAIN_LOOP
    
    CMP DX, 6
    JE HORZSTR
    CMP DX, 7
    JE VERTSTR
    CMP DX, 8
    JE CHECKERED
    CMP DX, 9
    JE CLOSE
    
    JMP MAIN_LOOP

DISPLAY_MENU:
    MOV AH, 06h         ; clear screen
    XOR AL, AL      
    XOR CX, CX
    MOV DX, 184Fh 
    MOV BH, 10011110B      ; 001Eh
    INT 10h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 3
    MOV DL, 36
    INT 10h
    LEA DX, txt1
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 6
    MOV DL, 0
    INT 10h
    LEA DX, txt2
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 7
    MOV DL, 0
    INT 10h
    LEA DX, txt3
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 8
    MOV DL, 0
    INT 10h
    LEA DX, txt4
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 9
    MOV DL, 0
    INT 10h
    LEA DX, txt5
    MOV AH, 09h
    INT 21h

    MOV AH, 02h
    MOV BH, 0
    MOV DH, 11
    MOV DL, 18
    INT 10h
    LEA DX, txt6
    MOV AH, 09h
    INT 21h
    
    RET

HORZSTR:
    MOV AH, 06h
    XOR AL, AL
    MOV BH, 00001111b
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h
    
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 01000000b
    MOV CH, 0
    MOV CL, 0
    MOV DH, 5
    MOV DL, 79
    INT 10h
    
    MOV BH, 00100000b
    MOV CH, 6
    MOV CL, 0
    MOV DH, 11
    MOV DL, 79
    INT 10h
    
    MOV BH, 00010000b
    MOV CH, 12
    MOV CL, 0
    MOV DH, 17
    MOV DL, 79
    INT 10h
    
    MOV BH, 01110000b
    MOV CH, 18
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    INT 10h
    
    JMP WAIT_KEY

VERTSTR: 
    MOV AH, 06h
    XOR AL, AL
    MOV BH, 00001111b
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h
    
    MOV AH, 06h
    MOV AL, 0
    MOV BH, 01000000b
    MOV CH, 0
    MOV CL, 0
    MOV DH, 24
    MOV DL, 19
    INT 10h
    
    MOV BH, 00100000b
    MOV CH, 0
    MOV CL, 20
    MOV DH, 24
    MOV DL, 39
    INT 10h
    
    MOV BH, 00010000b
    MOV CH, 0
    MOV CL, 40
    MOV DH, 24
    MOV DL, 59
    INT 10h
    
    MOV BH, 01110000b
    MOV CH, 0
    MOV CL, 60
    MOV DH, 24
    MOV DL, 79
    INT 10h
    
    JMP WAIT_KEY

CHECKERED:
    
    XOR AL, AL
    MOV  ah, 06h
    XOR  al, al
    MOV  bh, 0Fh
    MOV  cx, 0000h
    MOV  dx, 0513h
    INT 10h
    MOV  bh, 5Fh
    MOV  cx, 0014h
    MOV  dx, 0527h
    int  10h
    mov  bh, 6Fh
    mov  cx, 0028h
    mov  dx, 053Bh
    int  10h
    mov  bh, 1Fh
    mov  cx, 003Ch
    mov  dx, 054Fh
    int  10h

    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh
    mov  cx, 0600h
    mov  dx, 0B13h
    int  10h
    mov  bh, 0Fh
    mov  cx, 0614h
    mov  dx, 0B27h
    int  10h
    mov  bh, 5Fh
    mov  cx, 0628h
    mov  dx, 0B3Bh
    int  10h
    mov  bh, 6Fh
    mov  cx, 063Ch
    mov  dx, 0B4Fh
    int  10h

    mov  ah, 06h
    xor  al, al
    mov  bh, 6Fh
    mov  cx, 0C00h
    mov  dx, 1113h
    int  10h
    mov  bh, 1Fh
    mov  cx, 0C14h
    mov  dx, 1127h
    int  10h
    mov  bh, 0Fh
    mov  cx, 0C28h
    mov  dx, 113Bh
    int  10h
    mov  bh, 5Fh
    mov  cx, 0C3Ch
    mov  dx, 114Fh
    int  10h

    mov  ah, 06h
    xor  al, al
    mov  bh, 5Fh
    mov  cx, 1200h
    mov  dx, 1813h
    int  10h
    mov  bh, 6Fh
    mov  cx, 1214h
    mov  dx, 1827h
    int  10h
    mov  bh, 1Fh
    mov  cx, 1228h
    mov  dx, 183Bh
    int  10h
    mov  bh, 0Fh
    mov  cx, 123Ch
    mov  dx, 184Fh
    int  10h

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 22
    mov  dl, 27
    int  10h 
    jmp  WAIT_KEY
    call DISPLAY_MENU

    mov  ah, 00h
    int  16h
    jmp  WAIT_KEY

WAIT_KEY:
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12
    MOV DL, 28
    INT 10h
    LEA DX, txt7
    MOV AH, 09h
    INT 21h
    
    MOV AH, 00h
    INT 16h
    
    JMP START

ERR:
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12
    MOV DL, 30
    INT 10h
    LEA DX, txt8
    MOV AH, 09h
    INT 21h
    
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 14
    MOV DL, 20
    INT 10h
    LEA DX, txt9
    MOV AH, 09h
    INT 21h
    
    MOV AH, 00h
    INT 16h
    JMP START

CLOSE:
    MOV AX, 0002h
    INT 33h
    
    MOV AH, 4Ch
    INT 21h

ret  

.data
txt1 DB ' MENU $'
txt2 DB '1 - HORIZONTAL STRIPES $'
txt3 DB '2 - VERTICAL STRIPES $'
txt4 DB 'F1 - CHECKERED PATTERN $'
txt5 DB 'Q - QUIT $'
txt6 DB 'ENTER CHOICE $'
txt7 DB 'Press any key to continue $' 
txt8 DB 'Error$'
txt9 DB 'Use 1,2,F1,Q or click with mouse$'