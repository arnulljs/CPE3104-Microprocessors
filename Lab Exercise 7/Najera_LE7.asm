;=============================================================
; 8086 INTERRUPT PROGRAM WITH 8255 & 8259 INTERFACE
;=============================================================

PROCED1 SEGMENT
ISR1 PROC FAR
    ASSUME CS:PROCED1, DS:DATA
    ORG 01000H

    PUSHF                  ; Save flags
    PUSH AX                ; Save registers
    PUSH DX

    MOV DX, PORTC
    IN  AL, DX
    AND AL, 0FH

    ;------------------------------
    ; Check keypad input (PORTC)
    ;------------------------------
    CMP AL, 00H    JE _ONE
    CMP AL, 01H    JE _TWO
    CMP AL, 02H    JE _THREE
    CMP AL, 04H    JE _FOUR
    CMP AL, 05H    JE _FIVE
    CMP AL, 06H    JE _SIX
    CMP AL, 08H    JE _SEVEN
    CMP AL, 09H    JE _EIGHT
    CMP AL, 0AH    JE _NINE
    CMP AL, 0CH    JE _DASH
    CMP AL, 0DH    JE _ZERO
    CMP AL, 0EH    JE _DASH

;------------------------------
; Output corresponding display
;------------------------------
_ZERO:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB0
    OUT DX, AL
    JMP END_CHECK

_ONE:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB1
    OUT DX, AL
    JMP END_CHECK

_TWO:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB2
    OUT DX, AL
    JMP END_CHECK

_THREE:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB3
    OUT DX, AL
    JMP END_CHECK

_FOUR:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB4
    OUT DX, AL
    JMP END_CHECK

_FIVE:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB5
    OUT DX, AL
    JMP END_CHECK

_SIX:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB6
    OUT DX, AL
    JMP END_CHECK

_SEVEN:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB7
    OUT DX, AL
    JMP END_CHECK

_EIGHT:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB8
    OUT DX, AL
    JMP END_CHECK

_NINE:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMB9
    OUT DX, AL
    JMP END_CHECK

_DASH:
    MOV CL, AL
    MOV DX, PORTA
    MOV AL, NUMBN
    OUT DX, AL
    JMP END_CHECK

END_CHECK:
    POP DX
    POP AX
    POPF
    IRET

ISR1 ENDP
PROCED1 ENDS


;=============================================================
; SECOND INTERRUPT SERVICE ROUTINE
;=============================================================

PROCED2 SEGMENT
ISR2 PROC FAR
    ASSUME CS:PROCED2, DS:DATA
    ORG 02000H

    PUSHF
    PUSH AX
    PUSH DX

    ;------------------------------
    ; Check CL value (from ISR1)
    ;------------------------------
    CMP CL, 00H    JE _ONE
    CMP CL, 01H    JE _TWO
    CMP CL, 02H    JE _THREE
    CMP CL, 04H    JE _FOUR
    CMP CL, 05H    JE _FIVE
    CMP CL, 06H    JE _SIX
    CMP CL, 08H    JE _SEVEN
    CMP CL, 09H    JE _EIGHT
    CMP CL, 0AH    JE _NINE
    CMP CL, 0CH    JE _DASH
    CMP CL, 0DH    JE _ZERO
    CMP CL, 0EH    JE _DASH

;------------------------------
; Display corresponding output
;------------------------------
_ZERO:
    MOV DX, PORTB
    MOV AL, NUMB0
    OUT DX, AL
    JMP END_CHECK

_ONE:
    MOV DX, PORTB
    MOV AL, NUMB1
    OUT DX, AL
    JMP END_CHECK

_TWO:
    MOV DX, PORTB
    MOV AL, NUMB2
    OUT DX, AL
    JMP END_CHECK

_THREE:
    MOV DX, PORTB
    MOV AL, NUMB3
    OUT DX, AL
    JMP END_CHECK

_FOUR:
    MOV DX, PORTB
    MOV AL, NUMB4
    OUT DX, AL
    JMP END_CHECK

_FIVE:
    MOV DX, PORTB
    MOV AL, NUMB5
    OUT DX, AL
    JMP END_CHECK

_SIX:
    MOV DX, PORTB
    MOV AL, NUMB6
    OUT DX, AL
    JMP END_CHECK

_SEVEN:
    MOV DX, PORTB
    MOV AL, NUMB7
    OUT DX, AL
    JMP END_CHECK

_EIGHT:
    MOV DX, PORTB
    MOV AL, NUMB8
    OUT DX, AL
    JMP END_CHECK

_NINE:
    MOV DX, PORTB
    MOV AL, NUMB9
    OUT DX, AL
    JMP END_CHECK

_DASH:
    MOV DX, PORTB
    MOV AL, NUMBN
    OUT DX, AL
    JMP END_CHECK

END_CHECK:
    POP DX
    POP AX
    POPF
    IRET

ISR2 ENDP
PROCED2 ENDS


;=============================================================
; DATA SEGMENT
;=============================================================

DATA SEGMENT
    ORG 03000H

    PORTA  EQU 0F0H
    PORTB  EQU 0F2H
    PORTC  EQU 0F4H
    COM_REG EQU 0F6H
    PIC1   EQU 0F8H
    PIC2   EQU 0FAH

    ICW1 EQU 13H
    ICW2 EQU 80H
    ICW4 EQU 03H
    OCW1 EQU 0FCH

    ; 7-segment display encoding
    NUMB0 EQU 00111111B
    NUMB1 EQU 00000110B
    NUMB2 EQU 01011011B
    NUMB3 EQU 01001111B
    NUMB4 EQU 01100110B
    NUMB5 EQU 01101101B
    NUMB6 EQU 01111101B
    NUMB7 EQU 00000111B
    NUMB8 EQU 01111111B
    NUMB9 EQU 01101111B
    NUMBN EQU 01000000B

DATA ENDS


;=============================================================
; STACK SEGMENT
;=============================================================

STK SEGMENT STACK
    BOS DW 64 DUP(?)
    TOS LABEL WORD
STK ENDS


;=============================================================
; MAIN CODE SEGMENT
;=============================================================

CODE SEGMENT PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STK
    ORG 03000H

START:
    ; Set up segments
    MOV AX, DATA
    MOV DS, AX

    MOV AX, STK
    MOV SS, AX
    LEA SP, TOS

    CLI                      ; Disable interrupts

    ;------------------------------
    ; Configure 8255
    ;------------------------------
    MOV DX, COM_REG
    MOV AL, 81H
    OUT DX, AL

    ;------------------------------
    ; Configure 8259
    ;------------------------------
    MOV DX, PIC1
    MOV AL, ICW1
    OUT DX, AL

    MOV DX, PIC2
    MOV AL, ICW2
    OUT DX, AL

    MOV AL, ICW4
    OUT DX, AL

    MOV AL, OCW1
    OUT DX, AL

    STI                      ; Enable interrupts

    ;------------------------------
    ; Set Interrupt Vector Table
    ;------------------------------
    MOV AX, OFFSET ISR1
    MOV [ES:200H], AX
    MOV AX, SEG ISR1
    MOV [ES:202H], AX

    MOV AX, OFFSET ISR2
    MOV [ES:204H], AX
    MOV AX, SEG ISR2
    MOV [ES:206H], AX

    ;------------------------------
    ; Foreground routine
    ;------------------------------
    MOV DX, PORTA
    MOV AL, NUMB0
    OUT DX, AL

    MOV DX, PORTB
    MOV AL, NUMB0
    OUT DX, AL

MAIN_LOOP:
    CALL DELAY_5MS
    CALL DELAY_5MS

    MOV DX, PORTC
    MOV AL, 80H
    OUT DX, AL

    CALL DELAY_5MS
    CALL DELAY_5MS

    MOV AL, 00H
    OUT DX, AL

    JMP MAIN_LOOP


;=============================================================
; Delay Subroutine (Approx. 5ms)
;=============================================================
DELAY_5MS:
    MOV BX, 0DF2H
DELAY_LOOP:
    DEC BX
    NOP
    JNZ DELAY_LOOP
    RET

CODE ENDS
END START