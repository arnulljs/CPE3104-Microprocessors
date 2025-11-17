; THREE INITIALS PROCED
PROCED1 SEGMENT 'CODE'	
ON_OFF PROC FAR		;when i press the switch1
						;this ISR will run, toggling the flag to its opposite state
ASSUME CS:PROCED1, DS:DATA
ORG 00000H
   PUSHF
   PUSH AX
   PUSH DX
   CMP ON_FLAG, 1 		;check if circuit is marked on
   JE RESET_ON			;if on, jump to reset
   MOV ON_FLAG, 1 		;if off, mark as on by setting 1 to on_flag
   MOV MODE_FLAG, 1		;automatically selects mode to mode 1
   JMP EXIT_ON_OFF		;exit procedure
   RESET_ON:
      MOV ON_FLAG, 0		;set on_flag to 0
      MOV PAUSE_FLAG, 0	;set pause_flag to 0
   EXIT_ON_OFF:			;general exit code
   POP DX 
   POP AX
   POPF
   IRET
ON_OFF ENDP
PROCED1 ENDS

;MOTOR ON/OFF PROCED
PROCED2 SEGMENT 'CODE'		;this checks whether the current state is paused or played. 
							 ;when called, it will set the flag to on or off. 
PAUSE_PLAY PROC FAR		;when i press the switch2, this ISR will run, toggling the flag to its opposite state
ASSUME CS:PROCED2, DS:DATA
ORG 00050H
   PUSHF
   PUSH AX
   PUSH DX
   CMP ON_FLAG, 1		;check if circuit is marked on
   JNE EXIT_PAUSE_PLAY	;if its off, exit out of procedure since its off, theres nothing to pause/play
   CMP PAUSE_FLAG, 1		;is pause_flag on
   JE RESET_PAUSE		;if pause_flag is on, jump to reset to mark it off
   MOV PAUSE_FLAG, 1		;if pause_flag is off, set/mark as on
   JMP EXIT_PAUSE_PLAY	;exit procedure
   RESET_PAUSE:			
      MOV PAUSE_FLAG, 0	;set pause_flag to off
   EXIT_PAUSE_PLAY:
   POP DX
   POP AX
   POPF
   IRET
PAUSE_PLAY ENDP
PROCED2 ENDS

;RED X NMI PROCED
PROCED3 SEGMENT 'CODE'
MODES PROC FAR			;when i press the switch3 this ISR will run, toggling the flag to its opposite state
ASSUME CS:PROCED3, DS:DATA
ORG 00100H
   PUSHF
   PUSH AX
   PUSH DX
   CMP MODE_FLAG, 1		;increment mode_flag to move to next mode. mode=1++ = mode=2. so on so forth until mode_flag 4
   JE RESET_MODE
   MOV MODE_FLAG, 1		;if it is 4, which is the range when its invalid, then loop back to 1
   JMP EXIT_MODE
   RESET_MODE:
      MOV MODE_FLAG, 0
   EXIT_MODE:				;general exit
   POP DX
   POP AX
   POPF
   IRET
MODES ENDP
PROCED3 ENDS

DATA SEGMENT
ORG 00250H
   PORTA EQU 0F0H	; 8255 PPI
   PORTB EQU 0F2H
   PORTC EQU 0F4H
   COM_REG1 EQU 0F6H
   PIC1 EQU 0E0H	; address decoding where A0=A1=0 for icw
   PIC2 EQU 0E2H	; address decoding where A0=A1=1 for ocw
   ICW1 EQU 013H  	;00010011 (0), (a7-a5 interrupt vector address), 1, (1=level triggered, 0=edge triggered), 
				;(1=interval of 4, 0=interval of 8), (1=single, 0=cascade), (1=icw4 needed, 0=icw4 not needed)
   ICW2 EQU 080H	;10000000 interrupt vector address range start (10000000 for 80h start, 01110000 for 70h start, etc)
   ICW4 EQU 003H	;00000011 1,0,0,0, (1=special fully nested mode, 0=not special fully nested mode), 
				;(0x = non buffered, 10 = buffered/slave, 11 = buffered/master), (1=auto eoi, 0=normal eoi), (1=8086 mode, 0=mcs80 mode)
   OCW1 EQU 0F8H	;11111000 how many IR ports youre using, set ports to 0 if youre using. (3 ports, 11111000, 2 ports, 11111100)
   ON_FLAG DB 0
   PAUSE_FLAG DB 0
   MODE_FLAG DB 1
   TEMP DB ?
DATA ENDS

STK SEGMENT STACK
   BOS DW 64d DUP (?)
   TOS LABEL WORD
STK ENDS

CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STK
	ORG 00300H
START:
   MOV AX, DATA
   MOV DS, AX		; set the Data Segment address
   MOV AX, STK
   MOV SS, AX		; set the Stack Segment address
   LEA SP, TOS		; set SP as Top of Stack
   CLI
   
   MOV DX, COM_REG1	; Configuring 8255 PPI
   MOV AL, 10001001B
   OUT DX, AL
   	
   MOV AL, ICW1		; Configuring 8259
   OUT PIC1, AL
   MOV AL, ICW2
   OUT PIC2, AL
   MOV AL, ICW4
   OUT PIC2, AL
   MOV AL, OCW1
   OUT PIC2, AL
   STI
   
   ; Storing interrupt vector to interrupt vector table in memory
   MOV AX, OFFSET ON_OFF		
   MOV [ES:200H], AX			;calculated from their interrupt vector address x 4, 80H x 4 = 200H
   MOV AX, SEG ON_OFF
   MOV [ES:202H], AX			;next even for stack segment
   MOV AX, OFFSET PAUSE_PLAY
   MOV [ES:204H], AX			;calculated from their interrupt vector address x 4, 81H x 4 = 204H
   MOV AX, SEG PAUSE_PLAY
   MOV [ES:206H], AX			;next even for stack segment
   MOV AX, OFFSET MODES
   MOV [ES:208H], AX			;calculated from their interrupt vector address x 4, 82H x 4 = 208H
   MOV AX, SEG MODES
   MOV [ES:20AH], AX			;next even for stack segment
   
   ; foreground routine
   HERE:
      MOV AL, 00000000B		;set all columns to off
      OUT PORTA, AL
      MOV AL, 11111111B		;set all rows to on
      OUT PORTB, AL
      MOV AL, 00000000B
      OUT PORTC, AL					;mode3 subroutine
      CMP ON_FLAG, 0			;if on_flag is off, keep looping
      JE HERE					;if on_flag in on, proceed
      CMP PAUSE_FLAG, 1		;if pause_flag is on, jump to pause subroutine
      JE PAUSE					;pause subroutine
      CMP MODE_FLAG, 0			;if mode=3, jump to mode3
      JE NMI
      CMP MODE_FLAG, 1			;if mode=1, jump to mode1
      JE DEFAULT				;mode1 subroutine
      CMP MODE_FLAG, 2			;if mode=2, jump to mode2
      JE STICKMAN				;mode2 subroutine
      
   JMP HERE					;loop here
   
   ; Mode 1
   DEFAULT:
      MOV SI, OFFSET FONT_1
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_1
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_2
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_2
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_3
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_3
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_4
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_4
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_5
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_5
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_6
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_6
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_7
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_7
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_8
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_8
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_9
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_9
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_10
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_10
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_11
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_11
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_12
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_12
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_13
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_13
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_14
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_14
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_15
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_15
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_16
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_16
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_17
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_17
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_18
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_18
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_19
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_19
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_20
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_20
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_21
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_21
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_22
      CALL PRINT_CHAR
      MOV SI, OFFSET FONT_22
      CALL PRINT_CHAR
   JMP HERE
   
   ; Mode 2
   STICKMAN:
      MOV SI, OFFSET STICKMAN_1
      CALL PRINT_CHAR
      MOV SI, OFFSET STICKMAN_1
      CALL PRINT_CHAR
      MOV SI, OFFSET STICKMAN_2
      CALL PRINT_CHAR
      MOV SI, OFFSET STICKMAN_2
      CALL PRINT_CHAR
   CON_SM:
   JMP HERE
   
   ; Mode 3
   NMI:
      MOV SI, OFFSET NMI_1
      CALL PRINT_CHAR
      MOV SI, OFFSET NMI_2
      CALL PRINT_CHAR
   JMP HERE
   
   ; Print character from the specified font
   PRINT_CHAR:
      MOV AH, 11111110B	;column mask i guess since active low, col1 = bit 0 is on, this turns on first column, the lsb column
      MOV DI, SI				;si is current column font data, di is the start of the character. so im moving current column font to start of the character
      MOV AL, MODE_FLAG	;mov mode into al
      MOV TEMP, AL			; move mode_flag value into temp
   F1:
      CMP PAUSE_FLAG, 1
      JE PAUSE				;if its paused, jump to pause
      MOV AL, AH			;move into al the column mask
      OUT PORTB, AL		;portb or porta idk
      MOV AL, BYTE PTR CS:[SI] ; Get the character to print, this means i want ONE BYTE (8 bits) (BYTE PTR) from where the font data is stored (CS:), 
						  ;specifically the current byte of the font data ([SI]) 
						  ;I only want one byte inside the code segment where the font data is stored at the current position
      OUT PORTA, AL		;output row data
      CMP ON_FLAG, 0		;is the circuit even on
      JE HERE				;if its not, then jump back to here in which the circuit is turned off at the start
      CALL DELAY_250MS	;if it is on, delay by 250ms
      MOV AL, 00H			;then clear row data
      OUT PORTA, AL		;output cleared row data
      INC SI				;remember, SI points to the current position of row and column data. INC moves it to the next byte? this also causes it to shift to the left instead because it builds from lsb.
      CLC
      ROL AH, 1				;this moves the active 0 bit in ah to the left. Each rotation shifts the active column to the next physical column on the LED matrix.
      CALL DELAY_500MS
      JC F1
   RET
   
   PAUSE:
      MOV SI, DI
      MOV AH, 11111110B
   F2:
      CMP PAUSE_FLAG, 0
      JE UNPAUSE
      MOV AL, AH
      OUT PORTB, AL
      MOV AL, BYTE PTR CS:[SI] ; Get the character to print
      OUT PORTA, AL
      CMP ON_FLAG, 0
      JE HERE
      CALL DELAY_250MS
      MOV AL, 00H
      OUT PORTA, AL
      INC SI
      CLC
      ROL AH, 1
      JC F2
      JMP HERE
   UNPAUSE:
      MOV AL, MODE_FLAG
      CMP TEMP, AL
      JNE CHECK_MODE
      RET
      CHECK_MODE:
      CMP MODE_FLAG, 1
      JE DEFAULT
      CMP MODE_FLAG, 2
      JE STICKMAN
      CMP MODE_FLAG, 0
      JE NMI
      
   OFF:
      MOV AL, 00000000B
      OUT PORTA, AL
      MOV AL, 11111111B
      OUT PORTB, AL
      MOV ON_FLAG, 0
      MOV MODE_FLAG, 1
   JMP HERE
      
   DELAY_250MS:	MOV CX, 250
   TIMER1:
      NOP
      NOP
      NOP
      NOP
      LOOP TIMER1
   RET
   
   DELAY_500MS:	MOV CX, 00FFH	; not 500MS
   L2:
      NOP
      NOP
      LOOP L2
   RET

   DELAY_1MS:	MOV BX, 02CAH
   L1:
      DEC BX
      NOP
      JNZ L1
      RET
   RET

; Characters Data to display on 3x5 LED Matrix
FONT_1:
      DB 00001110B
      DB 00010001B
      DB 00010001B
      DB 00011111B
      DB 00010001B
      DB 00010001B
      DB 00010001B

FONT_2:
      DB 00000111B
      DB 00001000B
      DB 00001000B
      DB 00001111B
      DB 00001000B
      DB 00001000B
      DB 00001000B

FONT_3:
      DB 00000011B
      DB 00000100B
      DB 00000100B
      DB 00010111B
      DB 00000100B
      DB 00000100B
      DB 00000100B

FONT_4: ;show a little
      DB 00010001B
      DB 00010010B
      DB 00010010B
      DB 00010011B
      DB 00010010B
      DB 00010010B
      DB 00010010B

FONT_5: ;show more
      DB 00011000B
      DB 00001001B
      DB 00001001B
      DB 00011001B
      DB 00001001B
      DB 00001001B
      DB 00001001B

FONT_6: ;show mid
      DB 00011100B
      DB 00000100B
      DB 00000100B
      DB 00011100B
      DB 00000100B
      DB 00000100B
      DB 00000100B

FONT_7: ;show cut
      DB 00001110B
      DB 00010010B
      DB 00010010B
      DB 00001110B
      DB 00010010B
      DB 00010010B
      DB 00010010B

FONT_8: ;show small
      DB 00000111B
      DB 00001001B
      DB 00001001B
      DB 00000111B
      DB 00001001B
      DB 00001001B
      DB 00001001B

FONT_9:
      DB 00000011B
      DB 00000100B
      DB 00000100B
      DB 00000011B
      DB 00000100B
      DB 00000100B
      DB 00000100B

FONT_10:
      DB 00010001B
      DB 00010010B
      DB 00010010B
      DB 00010001B
      DB 00010010B
      DB 00010010B
      DB 00010010B

FONT_11:
      DB 00011000B
      DB 00001001B
      DB 00001001B
      DB 00001000B
      DB 00001001B
      DB 00001001B
      DB 00001001B

FONT_12:
      DB 00001100B
      DB 00010100B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      
FONT_13:
      DB 00000110B
      DB 00001010B
      DB 00010010B
      DB 00010010B
      DB 00010010B
      DB 00000010B
      DB 00000010B
      
FONT_14:
      DB 00000011B
      DB 00000101B
      DB 00001001B
      DB 00001001B
      DB 00001001B
      DB 00010001B
      DB 00000001B
      
FONT_15:
      DB 00000001B
      DB 00000010B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00001000B
      DB 0001000B

FONT_16:
      DB 00010000B
      DB 00010001B
      DB 00010010B
      DB 00010010B
      DB 00010010B
      DB 00010100B
      DB 00011000B
      
FONT_17:
      DB 00001000B
      DB 00001000B
      DB 00001001B
      DB 00001001B
      DB 00001001B
      DB 00001010B
      DB 00001100B
      
FONT_18:
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00000101B
      DB 00000110B
      
FONT_19:
      DB 00000010B
      DB 00010010B
      DB 00010010B
      DB 00010010B
      DB 00010010B
      DB 00010010B
      DB 00010011B

FONT_20:
      DB 00010001B
      DB 00001001B
      DB 00001001B
      DB 00011001B
      DB 00001001B
      DB 00001001B
      DB 00001001B

FONT_21:
      DB 00011000B
      DB 00000100B
      DB 00000100B
      DB 00011100B
      DB 00000100B
      DB 00000100B
      DB 00000100B

FONT_22:
      DB 00011100B
      DB 00000010B
      DB 00000010B
      DB 00011110B
      DB 00000010B
      DB 00000010B
      DB 00000010B
   
STICKMAN_1:
      DB 00000100B
      DB 00001010B
      DB 00000100B
      DB 00011111B
      DB 00000100B
      DB 00001010B
      DB 00001010B
 
STICKMAN_2:
      DB 00001010B
      DB 00010101B
      DB 00001110B
      DB 00000100B
      DB 00001010B
      DB 00010001B
      DB 00000000B

NMI_1:
      DB 00010001B
      DB 00001010B
      DB 00000100B
      DB 00000100B
      DB 00000100B
      DB 00001010B
      DB 00010001B

NMI_2:
      DB 00000000B
      DB 00000000B
      DB 00000000B
      DB 00000000B
      DB 00000000B
      DB 00000000B
      DB 00000000B

      
CODE ENDS 
END START
