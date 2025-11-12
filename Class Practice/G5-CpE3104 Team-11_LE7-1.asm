PROCED1 SEGMENT
ISR1 PROC FAR
ASSUME CS:PROCED1, DS:DATA
ORG 01000H ; write code within below starting at address 08000H
   PUSHF ; push 16-bit operands
   PUSH AX ; save program context
   PUSH DX
   
   ;<write the ISR code here>
   MOV DX, PORTA
   MOV AL, 09H
   OUT DX, AL
   
   POP DX ; retrieve program context
   POP AX
   POPF ; pop 16-bit operands
   IRET ; return from interrupt
ISR1 ENDP ; end of procedure
PROCED1 ENDS

PROCED2 SEGMENT
ISR2 PROC FAR
ASSUME CS:PROCED2, DS:DATA
ORG 02000H ; write code within below starting at address 09000H
   PUSHF ; push 16-bit operands
   PUSH AX ; save program context
   PUSH DX
   
   ;<write the ISR code here>
   MOV DX, PORTA
   MOV AL, 00H
   OUT DX,AL
   
   POP DX ; retrieve program context
   POP AX
   POPF ; pop 16-bit operands
   IRET ; return from interrupt
ISR2 ENDP ; end of procedure
PROCED2 ENDS

DATA SEGMENT
   ORG 03000H
   PORTA EQU 0F0H ; PORTA address
   PORTB EQU 0F2H ; PORTB address
   PORTC EQU 0F4H ; PORTC address
   COM_REG EQU 0F6H ; Command Register Address
   PIC1 EQU 0F8H ; A1 = 0
   PIC2 EQU 0FAH ; A1 = 1
   ICW1 EQU 13H ; refer to #4
   ICW2 EQU 80H ; refer to #4
   ICW4 EQU 03H ; refer to #4
   OCW1 EQU 0FCH ; refer to #4
DATA ENDS

STK SEGMENT STACK
   BOS DW 64d DUP(?) ; stack depth (bottom of stack)
   TOS LABEL WORD ; top of stack
STK ENDS

CODE SEGMENT PUBLIC 'CODE'
   ASSUME CS:CODE, DS:DATA, SS:STK
   ORG 08000H ; write code within below starting at address 0E000H
   START:
      MOV AX, DATA
      MOV DS, AX ; set the Data Segment address
      MOV AX, STK
      MOV SS, AX ; set the Stack Segment address
      LEA SP, TOS ; set address of SP as top of stack
      CLI ; clears IF flag
      
      ;program the 8255
      MOV DX, COM_REG
      MOV AL,89H
      OUT DX, AL
      
      ;program the 8259
      MOV DX, PIC1 ; set I/O address to access ICW1
      MOV AL, ICW1
      OUT DX, AL ; send command word
      MOV DX, PIC2 ; set I/O address to access ICW2,ICW4 and OCW1
      MOV AL, ICW2
      OUT DX, AL ; send command word
      MOV AL, ICW4
      OUT DX, AL ; send command word
      MOV AL, OCW1
      OUT DX, AL ; send command word
      STI ; enable INTR pin of 8086
      
      MOV AX, OFFSET ISR1 ; get offset address of ISR1 (IP)
      MOV [ES:200H], AX ; store offset address to memory at 200H
      MOV AX, SEG ISR1 ; get segment address of ISR1 (CS)
      MOV [ES:202H], AX ; store segment address to memory at 202H
      MOV AX, OFFSET ISR2 ; get offset address of ISR2 (IP)
      MOV [ES:204H], AX ; store offset address to memory at 204H
      MOV AX, SEG ISR2 ; get segment address of ISR2 (CS)
      MOV [ES:206H], AX ; store segment address to memory at 206H
  
  ;foreground routine
   HERE:
      ;<insert foreground routine code here>
      _WAIT:
      MOV DX, PORTC
      IN AL, DX
      AND AL, 0FH
      
      CMP AL, 09H
      JG GREATER
      
      MOV DX, PORTB
      OUT DX, AL
      JMP _WAIT
      
      GREATER:
	 MOV DX, PORTB
	 MOV AL, 00H
	 OUT DX, AL
	 
      JMP HERE
      
CODE ENDS
END START