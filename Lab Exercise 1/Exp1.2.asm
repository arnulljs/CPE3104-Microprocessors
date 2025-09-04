; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

MOV BX, 0123H
MOV AX, 0456H
ADD AX, BX
SUB AX, BX
PUSH AX
PUSH BX

ret




