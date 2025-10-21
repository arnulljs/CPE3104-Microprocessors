;Write an assembly program to increment the two-digit counter (PORTB & PORTA) when the
;switch in PORTC is pressed. Upon reset, the value of the counter is “00”. When the counter
;reaches “99”, it reverts back to “00” on the next increment. Apply a simple (10 ms delay)
;software switch debouncing to make it function properly.  

;ARNOLD JOSEPH NAJERA
;BS CPE 3

DATA SEGMENT
    PORTA   EQU 0F0H        ; PORTA address (LSD)
    PORTB   EQU 0F2H        ; PORTB address (MSD)
    PORTC   EQU 0F4H        ; PORTC address (Switch input)
    COM_REG EQU 0F6H        ; Command Register address

    TABLE DB 0C0H,0F9H,0A4H,0B0H,099H,092H,082H,0F8H,080H,090H
    LSD    DB 0             ; Least significant digit (0-9)
    MSD    DB 0             ; Most significant digit (0-9)
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE, DS:DATA

START:
    MOV AX, DATA
    MOV DS, AX
    MOV DX, COM_REG
    MOV AL, 10001000B       ; PORTA=out, PORTB=out, PC upper=out, PC lower=in
    OUT DX, AL

    MOV BYTE PTR LSD, 0
    MOV BYTE PTR MSD, 0
    CALL DISPLAY

MAIN_LOOP:
    MOV DX, PORTC
    IN  AL, DX
    TEST AL, 01H            ; check PC0 bit
    JZ MAIN_LOOP            ; if 0, not pressed ? loop

    CALL DELAY              ; 10 ms debounce delay
    IN  AL, DX              ; read again
    TEST AL, 01H
    JZ MAIN_LOOP            ; if released after debounce, ignore

    INC BYTE PTR LSD
    CMP BYTE PTR LSD, 10
    JB NO_ROLLOVER
    MOV BYTE PTR LSD, 0
    INC BYTE PTR MSD
    CMP BYTE PTR MSD, 10
    JB NO_ROLLOVER
    MOV BYTE PTR MSD, 0     ; reset to 00 after 99

NO_ROLLOVER:
    CALL DISPLAY

WAIT_RELEASE:
    IN  AL, DX
    TEST AL, 01H
    JNZ WAIT_RELEASE        ; stay here until released

    JMP MAIN_LOOP

DISPLAY PROC
    ; Display LSD
    MOV BL, LSD
    MOV SI, OFFSET TABLE
    MOV AL, [SI+BX]
    MOV DX, PORTA
    OUT DX, AL

    ; Display MSD
    MOV BL, MSD
    MOV AL, [SI+BX]
    MOV DX, PORTB
    OUT DX, AL
    RET
DISPLAY ENDP


DELAY PROC
    MOV CX, 0FFFFH
DELAY_LOOP:
    NOP
    LOOP DELAY_LOOP
    RET
DELAY ENDP

CODE ENDS
END START
