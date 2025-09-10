org 100h

.code

START:

MOV AH, 06H     ;clear screen , white on blue
XOR AL, AL      
XOR CX, CX
MOV DX, 184FH 
MOV BH, 10011110B
INT 10H

MOV AL, 03H  ; Set coordinate to 36,3 for txt1
MOV AH, 02H
MOV BH, 0
MOV DH, 3
MOV DL, 36
INT 10H  

LEA DX, txt1
MOV AH, 09H
INT 21H   

MOV AL, 03H  ; (0,6) for txt2
MOV AH, 02H
MOV BH, 0
MOV DH, 6
MOV DL, 0
INT 10H   

LEA DX, txt2
MOV AH, 09H
INT 21H 

MOV AL, 03H  ; (0,7) for txt3
MOV AH, 02H
MOV BH, 0
MOV DH, 7
MOV DL, 0
INT 10H

LEA DX, txt3
MOV AH, 09H
INT 21H      

MOV AL, 03H  ; (0,9) for txt4
MOV AH, 02H
MOV BH, 0
MOV DH, 9
MOV DL, 0
INT 10H

LEA DX, txt4
MOV AH, 09H
INT 21H

MOV AL, 03H ;(18,11) for txt5
MOV AH, 02H
MOV BH, 0
MOV DH, 11
MOV DL, 18
INT 10H

LEA DX, txt5
MOV AH, 09H
INT 21H
         
MOV AH, 01H
INT 21H
CMP AL, 49 
JE HORZSTR
CMP AL, 50
JE VERTSTR
CMP AL, 'q'
JE CLOSE 
CMP AL, 'Q'
JE CLOSE
JNE ERR  

    HORZSTR:
    
        XOR AL, AL     ; Clear entire screen
        MOV AH, 06h         
        MOV AL, 00h
        MOV BH, 00001111B    ; black
        MOV CH, 0
        MOV CL, 0
        MOV DH, 06
        MOV DL, 79
        INT 10H 
        
        MOV BH, 11101111B    ; yellow 
        MOV CH, 06
        MOV CL, 0
        MOV DH, 12
        MOV DL, 79
        INT 10h  
        
        MOV bh, 01000111B    ; red
        MOV ch, 12
        MOV cl, 0
        MOV dh, 18
        MOV dl, 79
        INT 10H 
         
        
              
        MOV AL, 03H          ; Press any key
        MOV AH, 02H
        MOV BH, 0
        MOV DH, 12
        MOV DL, 36
        INT 10H
        
        LEA DX, txt6
        MOV AH, 09H
        INT 21H
        
        MOV AH, 0
        INT 16H 
        JMP START
    
    VERTSTR: 
        XOR AL, AL     ; Clear 
        MOV AH, 06h
        MOV AL, 00h
        MOV BH, 00001111B    ;Red
        MOV CX, 0000h
        MOV DH, 25
        MOV DL, 20
        INT 10h 
        
        MOV BH, 11101111B    ; Magenta line
        MOV CH, 0
        MOV CL, 20
        MOV DH, 25
        MOV DL, 40
        INT 10h  
        
        MOV BH, 10111111B    ; Sky blue line
        MOV CH, 0
        MOV CL, 40
        MOV DH, 25
        MOV DL, 60
        INT 10H
        
        MOV AL, 03H          ; Press any key
        MOV AH, 02H
        MOV BH, 0
        MOV DH, 12
        MOV DL, 36
        INT 10H
       
        LEA DX, txt6         
        MOV AH, 09H
        INT 21H
        MOV AH, 0
        INT 16H
        JMP START
                
                 
        ERR:
        MOV AL, 03H
        MOV AH, 02H
        MOV BH, 0
        MOV DH, 12
        MOV DL, 36
        INT 10H  
        
        LEA DX, txt7
        MOV AH, 09H
        INT 21H  
        
        MOV AL, 03H
        MOV AH, 02H
        MOV BH, 0
        MOV DH, 16
        MOV DL, 37
        INT 10H
        
        LEA DX, txt6
        MOV AH, 09H
        INT 21H
        MOV AH, 0
        INT 16H
        JMP START  
        
        CLOSE:              ;Shuts the program off

        MOV AH, 0
        INT 21H
                 
ret  

.data

txt1 DB ' MENU $\'
txt2 DB '1 - HORIZONTAL STRIPES $\'
txt3 DB '2 - VERTICAL STRIPES $\'
txt4 DB 'Q - QUIT $\'
txt5 DB 'ENTER CHOICE $\'
txt6 DB 'Press any key to continue $\' 
txt7 DB 'Error$\'