;Write an assembly program that will create a running LED pattern (single cycle) on PORTA
;when the data in PORTC is 01H. When the data in PORTC is 02H, the 7-segment display in
;PORTB will count from 0-9. Nothing will happen if the data in PORTC is neither 01H or 02H.
;Compile and run the simulation. See appendix for details     

DATA SEGMENT
    PORTA EQU 0F0H     ; LEDs
    PORTB EQU 0F2H     ; 7-segment display
    PORTC EQU 0F4H     ; input (mode selector)
    TABLE DB 0C0H,0F9H,0A4H,0B0H,099H,092H,082H,0F8H,080H,090H
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA

    ORG 0000H

START:
    MOV AX, DATA
    MOV DS, AX

MAIN_LOOP:
    ; --- Read PORTC input ---
    MOV DX, PORTC
    IN  AL, DX

    CMP AL, 01H
    JE  RUNNING_LED      ; if PORTC = 01H

    CMP AL, 02H
    JE  COUNT_DISPLAY    ; if PORTC = 02H

    JMP MAIN_LOOP        ; otherwise do nothing

RUNNING_LED:
    MOV AL, 80H          ; start with 1000 0000b
LED_LOOP:
    MOV DX, PORTA
    OUT DX, AL           ; output LED pattern

    CALL DELAY           ; short delay

    SHR AL, 1            ; shift right
    JNZ LED_LOOP         ; repeat until AL = 00H

    JMP MAIN_LOOP

COUNT_DISPLAY:
    MOV CX, 0AH          ; 10 digits
    MOV SI, OFFSET TABLE
SEG_LOOP:
    MOV AL, [SI]         ; get digit code
    MOV DX, PORTB
    OUT DX, AL           ; output to 7-seg

    CALL DELAY           ; short delay

    INC SI
    LOOP SEG_LOOP

    JMP MAIN_LOOP


DELAY PROC
    MOV BX, 0FFFFH
WAIT1:
    NOP
    DEC BX
    JNZ WAIT1
    RET
DELAY ENDP

CODE ENDS
END START


;LE52-A

DATA SEGMENT
    PORTA EQU 0F0H ; PORTA address
    PORTB EQU 0F2H ; PORTB address
    PORTC EQU 0F4H ; PORTC address
DATA ENDS


CODE SEGMENT PUBLIC 'CODE'
ASSUME CS:CODE, DS:DATA
  

CODE SEGMENT
    MOV AX, DATA
    MOV DS, AX ; set the Data Segment address
    ORG 0000H ; write code below starting at address 0000H

START:
    MOV DX, PORTA ; set port address of PORTA
    MOV AL, 11110000B	; turn PORTA on
    OUT DX, AL ; send 1111000B to PORTA
HERE:
    NOP ; do nothing
    JMP HERE

CODE ENDS
END START 

;LE52-B   

DATA SEGMENT
    PORTA EQU 0F0H ; PORTA address
    PORTB EQU 0F2H ; PORTB address
    PORTC EQU 0F4H ; PORTC address
DATA ENDS

CODE SEGMENT
    MOV AX, DATA
    MOV DS, AX          ; set the Data Segment address
    ORG 0000H           ; write code below starting at address 0000H

START:
    MOV DX, PORTB       ; set port address of PORTB
    MOV AL, 10011001B   ; 7-segment code for '9'
    OUT DX, AL          ; send data to PORTB

HERE:
    NOP                 ; do nothing
    JMP HERE            ; infinite loop

CODE ENDS
END

;LE53-C

DATA SEGMENT
    PORTA EQU 0F0H ; PORTA address
    PORTB EQU 0F2H ; PORTB address
    PORTC EQU 0F4H ; PORTC address
DATA ENDS

CODE SEGMENT
    MOV AX, DATA
    MOV DS, AX          ; set the Data Segment address
    ORG 0000H           ; code starts at address 0000H

START:
MAIN_LOOP:
    MOV DX, PORTC       ; select PORTC (input from DIP switch)
    IN  AL, DX          ; read data from PORTC into AL

    MOV DX, PORTA       ; select PORTA (LEDs)
    OUT DX, AL          ; send the same data to PORTA

    JMP MAIN_LOOP       ; repeat forever to continuously update

CODE ENDS
END

;

