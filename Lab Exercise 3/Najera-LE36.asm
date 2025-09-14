;LE36.ASM   NAJERAaj    Date: 2025.09.10
ORG 100h
    push cs
    pop  ds

  LEA DX, STRING       
  MOV AH, 09h         
  INT 21h            
  
  CALL REVERSE         

  LEA DX, STRING       
  MOV AH, 09h           
  INT 21h              

RET

REVERSE:
 MOV CX, 23             

LOOP1:
  XOR AX, AX           
  MOV AL, [SI]          
  CMP AL, '$'           
  JE  LABEL1          
  PUSH AX              
  INC SI
  LOOP LOOP1          
  
LABEL1:
  MOV SI, OFFSET STRING 
  MOV CX, 23            

LOOP2:
  POP DX
  MOV [SI], DL          
  INC SI                
  LOOP LOOP2            

EXIT:
   MOV AH, 4Ch         
RET

STRING DB 'THIS IS A SAMPLE STRING$' 