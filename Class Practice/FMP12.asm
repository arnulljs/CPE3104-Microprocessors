Here is the full code for EMU8086 to program the 8255 with the command byte 93H, assuming the control register is at address 0F7H.

assembly
ORG 100H

; Program the 8255 PPI
; Command Byte: 10010011b = 93h
; PORTA: Input, Mode 0
; PORTB: Output, Mode 0
; PC0-PC3: Input
; PC4-PC7: Output

MOV AL, 93H     ; Load the control word into AL
OUT 0F7H, AL    ; Send control word to 8255 control register

; End of program
MOV AH, 4CH     ; DOS function to exit program
INT 21H         ; Call DOS interrupt

END
This code:

Sets up the 8255 configuration using the correct command byte (93H)

Sends it to the control register at I/O address F7H

Properly exits back to DOS using INT 21H function 4CH


Based on the 8255 control word format for Mode 0 operation:

*   **Bit 7 (Mode Set Flag):** Must be 1 for Active (1)
*   **Group A (Port A & Port C Upper)**
    *   **Bit 6, 5 (Port A Mode):** 00 for Mode 0
    *   **Bit 4 (Port A Direction):** 1 for Input
    *   **Bit 3 (Port C Upper Direction):** 0 for Output (PC4-PC7 as output)
*   **Group B (Port B & Port C Lower)**
    *   **Bit 2 (Port B Mode):** 0 for Mode 0
    *   **Bit 1 (Port B Direction):** 0 for Output
    *   **Bit 0 (Port C Lower Direction):** 1 for Input (PC0-PC3 as input)

Putting the bits together: **1 00 1 0 0 1 1**

Converting the binary `10010011` to hexadecimal gives the command byte: **93H**

**Code to program the 8255 (assuming the control register is at address 0F7H):**

```assembly
MOV AL, 93H   ; Load the command byte into AL
OUT 0F7H, AL  ; Output it to the 8255's control register
```

