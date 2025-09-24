ORG 100H

MAIN:
    MOV AL, '0'          ; Start with character '0'
    
DISPLAY_LOOP:
    OUT 0F2H, AL         ; Display digit on port F2H
    CALL DELAY_1MS       ; Wait for 1 second
    
    INC AL               ; Move to next character
    CMP AL, '9' + 1      ; Check if we passed '9'
    JNE DISPLAY_LOOP     ; If not, continue displaying
    
    MOV AL, '0'          ; Reset back to '0'
    JMP DISPLAY_LOOP     ; Continue forever

DELAY_1MS:
    MOV BX, 02CAH
L1:
    DEC BX
    NOP
    JNZ L1
    RET

END