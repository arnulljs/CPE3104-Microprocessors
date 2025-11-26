;ISR INT 80h 
PROCED1 SEGMENT 'CODE'
VPI PROC FAR
ASSUME CS:PROCED1, DS:DATA
ORG 00000H
   PUSHF
   PUSH AX
   PUSH DX
  CMP VPED_FLAG, 0
  JE VPED_ON
  JMP EXIT_VPED 		;Ignore if VPED_FLAG is 1, because that will be set to 0 at the start of every ped cycle
  VPED_ON:
      MOV VPED_FLAG, 1
  EXIT_VPED:
      POP DX
      POP AX
      POPF
      IRET
VPI ENDP
PROCED1 ENDS

;ISR INT 81h 
PROCED2 SEGMENT 'CODE'
HPI PROC FAR
ASSUME CS:PROCED2, DS:DATA
ORG 00050H
   PUSHF
   PUSH AX
   PUSH DX
  CMP HPED_FLAG, 0
  JE HPED_ON
  JMP EXIT_HPED 		;Ignore if HPED_FLAG is 1, because that will be set to 0 at the start of every ped cycle
  HPED_ON:
      MOV HPED_FLAG, 1
  EXIT_HPED:
      POP DX
      POP AX
      POPF
      IRET
HPI ENDP
PROCED2 ENDS


DATA SEGMENT
ORG 00250H
   ;8255 for vertical tl
    NSTL_PORTA   EQU 00H       ; 7-seg BCD outputs (output)
    NSTL_PORTB  EQU 02H       ; traffic light
    NSTL_PORTC   EQU 04H       ; Button input
    NSTL_COMREG  EQU 06H       ; 8255 control register
    
    ;8255 for verical ped
    VPED_PORTA	EQU 08H	; vertical matrix column
    VPED_PORTB	EQU 0AH	; vertical matrix row
    VPED_PORTC	EQU 0CH	; vertical BCD 7seg
    VPED_COMREG	EQU 0EH	; 8255 control register

    ;8255 for horizontal tl
    WETL_PORTA   EQU 10H       ; 7-seg BCD outputs (output)
    WETL_PORTB  EQU 12H       ; traffic light
    WETL_PORTC   EQU 14H       ; Button input
    WETL_COMREG  EQU 16H       ; 8255 control register
    
    ;8255 for horizontal ped
    HPED_PORTA	EQU 18H	; horizontal matrix column
    HPED_PORTB	EQU 1AH	; horizontal matrix row
    HPED_PORTC	EQU 1CH	; horizontal BCD 7seg
    HPED_COMREG	EQU 1EH	; 8255 control register
    
    ;8259
    PIC1 EQU 20H	;A0 8259= A1 OF ADDRESS 20H = A0 = 0	; ICW1
   PIC2 EQU 22H		;A0 8259= A1 OF ADDRESS 22H = A0 = 1	;ICW2, ICW4, OCW1
   ICW1 EQU 013H
   ICW2 EQU 080H	;80h-87h		IR0 - VERTICAL PED INT = 80H	IR1- HORIZONTAL PED INT = 81H
   ICW4 EQU 003H
   OCW1 EQU 0F8H	;1111 1000 = F8
   
    ;PED Button Flags
    HPED_FLAG DB 0
    VPED_FLAG DB 0
    ; pedestrian runtime state/counters
    VPED_ACTIVE DB 0
    HPED_ACTIVE DB 0
    VPED_PCH DB 0
    VPED_PCL DB 0
    HPED_PCH DB 0
    HPED_PCL DB 0
    VPED_ROW  DB 0
    HPED_ROW  DB 0
    
    ; traffic light counter
    START_TENS      EQU 02H	;MSB start	
    START_UNITS     EQU 00H	;LSB start
    LOW_RANGE_MAX   EQU 06H	;yellow
    
    CurHighLight DB 04H		;green
    HighToggle   DB 00H	
    
    ;all red clearance counter
    ALL_RED_TENS    EQU 00H    ; All-red = 04 seconds
    ALL_RED_UNITS   EQU 04H

    
DATA ENDS


STK SEGMENT STACK
   BOS DW 64d DUP (?)
   TOS LABEL WORD
STK ENDS


CODE 	SEGMENT PUBLIC 'CODE'
	 ASSUME CS:CODE, DS:DATA ,SS:STK
	 ORG 00300H
START:
   
   MOV AX, DATA
   MOV DS, AX		; set the Data Segment address
   MOV AX, STK
   MOV SS, AX		; set the Stack Segment address
   LEA SP, TOS		; set SP as Top of Stack
   CLI

    ;-----------------------------------------------
    ; Initialize 8255:
    ; Port A = output, Port B = output, Port C = input
    ;-----------------------------------------------
   
   ;8255 for vertical tl
    MOV DX, NSTL_COMREG 
    MOV AL, 89H          ; 1000 1001b -> A:out B:out C:in
    OUT DX, AL
    
   ;8255 for horizontal tl
    MOV DX, WETL_COMREG 
    MOV AL, 89H          ; 1000 1001b -> A:out B:out C:in
    OUT DX, AL
    
    ;8255 for vertical ped
    MOV DX, VPED_COMREG 
    MOV AL, 80H          ; 1000 0000b -> A:out B:out C:out
    OUT DX, AL
    
   ;8255 for horizontal ped
    MOV DX, HPED_COMREG 
    MOV AL, 80H          ; 1000 0000b -> A:out B:out C:out
    OUT DX, AL
    
    ; Configuring 8259
      MOV AL, ICW1		
      OUT PIC1, AL
     
      MOV AL, ICW2
      OUT PIC2, AL
      MOV AL, ICW4
      OUT PIC2, AL
      MOV AL, OCW1
      OUT PIC2, AL
      STI
      
       ; Storing interrupt vector to interrupt vector table in memory
  ;80h
  MOV AX, OFFSET VPI
   MOV [ES:200H], AX
   MOV AX, SEG VPI
   MOV [ES:202H], AX
   
   ;81h
   MOV AX, OFFSET HPI
   MOV [ES:204H], AX
   MOV AX, SEG HPI
   MOV [ES:206H], AX
   
    
    ; FOREGROUND ROUTINE???
    
    
RESET:
    XOR CX, CX
    CALL DISP
    MOV BYTE PTR HighToggle, 00H
    MOV BYTE PTR CurHighLight, 04H

WAIT_PRESS:
    ; poll PC0 until the push-button is asserted
    MOV DX, NSTL_PORTC
    IN  AL, DX
    AND AL, 01H          ; read PC0 only
    CMP AL, 01H
    JNE WAIT_PRESS       ; wait until button pressed

    CALL DELAY           ; debounce
    CALL DELAY
    MOV CH, START_TENS   ; preload countdown MS digit (configurable)
    MOV CL, START_UNITS  ; preload countdown LS digit (configurable)
    CALL SET_HIGH_LIGHT  ; drive first high-range traffic color + toggle state
    CALL DISP
    CALL UPDATE_LIGHTS

COUNT_LOOP:
    CALL DELAY           ; pacing delay
    CALL DELAY

CONT_DEC:
    ; borrow from tens when units digit rolls past zero
    CMP CL, 0
    JNE DEC_UNITS
    DEC CH
    MOV CL, 0AH

DEC_UNITS:
    DEC CL
    ; decrement pedestrian countdowns in sync when active
    CMP VPED_ACTIVE, 1
    JNE .no_vped_dec
    CMP BYTE PTR VPED_PCL, 0
    JNE .vped_dec_unit
    DEC BYTE PTR VPED_PCH
    MOV BYTE PTR VPED_PCL, 0AH
.vped_dec_unit:
    DEC BYTE PTR VPED_PCL
    ; if finished, clear ped active/request flags
    CMP BYTE PTR VPED_PCH, 0
    JNE .no_vped_dec
    CMP BYTE PTR VPED_PCL, 0
    JNE .no_vped_dec
    MOV BYTE PTR VPED_ACTIVE, 0
    MOV BYTE PTR VPED_FLAG, 0
.no_vped_dec:
    CMP HPED_ACTIVE, 1
    JNE .no_hped_dec
    CMP BYTE PTR HPED_PCL, 0
    JNE .hped_dec_unit
    DEC BYTE PTR HPED_PCH
    MOV BYTE PTR HPED_PCL, 0AH
.hped_dec_unit:
    DEC BYTE PTR HPED_PCL
    CMP BYTE PTR HPED_PCH, 0
    JNE .no_hped_dec
    CMP BYTE PTR HPED_PCL, 0
    JNE .no_hped_dec
    MOV BYTE PTR HPED_ACTIVE, 0
    MOV BYTE PTR HPED_FLAG, 0
.no_hped_dec:
    CMP CH, 0
    JNE DISP_NONZERO
    CMP CL, 0
    JE RELOAD_CYCLE
DISP_NONZERO:
    ; refresh pedestrian displays (one row per main-loop iteration) if active
    CMP BYTE PTR VPED_ACTIVE, 1
    JNE .no_vped_refresh
    CALL REFRESH_VPED_ROW
.no_vped_refresh:
    CMP BYTE PTR HPED_ACTIVE, 1
    JNE .no_hped_refresh
    CALL REFRESH_HPED_ROW
.no_hped_refresh:
    CALL DISP
    CALL UPDATE_LIGHTS
    JMP COUNT_LOOP

    
RELOAD_CYCLE:
    ; Insert All-Red clearance before switching directions
    CALL ALL_RED

    ; Now continue to the next phase (set the next high/low colors)
    CALL SET_HIGH_LIGHT

    MOV CH, START_TENS
    MOV CL, START_UNITS
    CALL DISP
    CALL UPDATE_LIGHTS

    ; Start pedestrian phase only when the direction that is currently red
    ; matches the requested pedestrian flag. CurHighLight holds the value
    ; written to NSTL_PORTB (vertical) by SET_HIGH_LIGHT. When CurHighLight=01h,
    ; vertical has RED; when CurHighLight=04h, horizontal has RED (because
    ; horizontal gets AL xor 05h).
    CMP VPED_FLAG, 1
    JNE .no_vped_start
    MOV AL, BYTE PTR CurHighLight
    CMP AL, 01H
    JNE .no_vped_start
    CALL VPED_PHASE
.no_vped_start:
    CMP HPED_FLAG, 1
    JNE .no_hped_start
    MOV AL, BYTE PTR CurHighLight
    CMP AL, 04H
    JNE .no_hped_start
    CALL HPED_PHASE
.no_hped_start:

    JMP COUNT_LOOP

;====================================================
; DISP — Display 2-digit number on 7-segments (BCD)
;         and binary equivalent on LEDs
;====================================================
DISP PROC
    ; convert tens/units digits into packed BCD for the dual 74LS48s
    ; Want: PORTB[7:4] = CH (tens), PORTB[3:0] = CL (units)
    ; Compute AL = CH * 16, then add CL (AL = (CH<<4) | CL)
    MOV AL, CH
    MOV BL, 16
    MUL BL               ; scale tens into upper nibble
    ADD AL, CL           ; merge units into lower nibble
    ;vertical timer
    MOV DX, NSTL_PORTA
    OUT DX, AL           ; put BCD nibbles on PORTB
   
   ;horizontal timer
    MOV DX, WETL_PORTA
    OUT DX, AL           ; put BCD nibbles on PORTB
    RET
DISP ENDP

UPDATE_LIGHTS PROC
    ; choose traffic color: high-range uses CurHighLight, =LOW_RANGE_MAX uses yellow
    CMP CH, 0
    JA UL_HIGH
    MOV AL, LOW_RANGE_MAX
    CMP CL, AL
    JA UL_HIGH
UL_LOW:
    MOV AL, 02H          ; yellow for final LOW_RANGE_MAX+1 counts
    JMP UL_WRITE
UL_HIGH:
    MOV AL, CurHighLight ; cached green/red for the high range
UL_WRITE:
    MOV DX, NSTL_PORTB
    OUT DX, AL
    MOV BL, AL
    CMP BL, 02H
    JE WRITE_WETL
    XOR BL, 05H
WRITE_WETL:
    MOV DX, WETL_PORTB
    MOV AL, BL
    OUT DX, AL
    RET
UPDATE_LIGHTS ENDP

SET_HIGH_LIGHT PROC
    ; alternate high-range color every restart (04H ? 01H)
    MOV AL, BYTE PTR HighToggle
    CMP AL, 0
    JNE SHL_GREEN
    MOV AL, 04H          ; first color (e.g., green)
    MOV BYTE PTR HighToggle, 1
    JMP SHL_STORE
SHL_GREEN:
    MOV AL, 01H          ; second color (e.g., red)
    MOV BYTE PTR HighToggle, 0
SHL_STORE:
    MOV BYTE PTR CurHighLight, AL
    MOV DX, NSTL_PORTB
    OUT DX, AL
    MOV BL, AL
    XOR BL, 05H
    MOV DX, WETL_PORTB
    MOV AL, BL
    OUT DX, AL
    RET
SET_HIGH_LIGHT ENDP


;====================================================
; Delay routine
;====================================================
DELAY PROC
    MOV BX, 01F5H         
DLY_LOOP:
    DEC BX
    NOP                  ; timing pad for stable delay
    JNZ DLY_LOOP
    RET
DELAY ENDP

;====================================================
; Small Delay routine
;====================================================
SMALL_DELAY PROC
    MOV AX, 1      ; adjust this value for more/less delay
DELAY_LOOP:
    DEC AX
    JNZ DELAY_LOOP
    RET
SMALL_DELAY ENDP

;====================================================
; ALL_RED — Applies all-red clearance interval
;            (forces both directions red and counts down)
;====================================================
ALL_RED PROC
    ; force both directions to RED (01H)
    MOV AL, 01H
    MOV DX, NSTL_PORTB
    OUT DX, AL
    MOV DX, WETL_PORTB
    OUT DX, AL

    ; load all-red countdown
    MOV CH, ALL_RED_TENS
    MOV CL, ALL_RED_UNITS

AR_LOOP:
    CALL DELAY
    CALL DELAY

    CALL DISP          ; display timer

    ; check CH:CL == 00
    CMP CH, 0
    JNE AR_CONT
    CMP CL, 0
    JE AR_DONE

AR_CONT:
    CMP CL, 0
    JNE AR_DEC_UNITS
    DEC CH
    MOV CL, 0AH

AR_DEC_UNITS:
    DEC CL
    JMP AR_LOOP

AR_DONE:
    RET
ALL_RED ENDP

;=======================
;
; FOR TESTING! FOR TESTING!
;
========================    
VPED_PHASE:
    ; Start vertical pedestrian: initialize active state and counters
    MOV BYTE PTR VPED_ACTIVE, 1
    MOV BYTE PTR VPED_ROW, 0
    MOV BYTE PTR VPED_PCH, START_TENS
    MOV BYTE PTR VPED_PCL, START_UNITS
    ; show initial ped countdown on VPED_PORTC
    MOV AL, BYTE PTR VPED_PCH
    SHL AL, 4
    OR AL, BYTE PTR VPED_PCL
    MOV DX, VPED_PORTC
    OUT DX, AL
    RET
;=======================
;
; FOR TESTING! FOR TESTING!
;
========================    
HPED_PHASE:
    ; Start horizontal pedestrian: initialize active state and counters
    MOV BYTE PTR HPED_ACTIVE, 1
    MOV BYTE PTR HPED_ROW, 0
    MOV BYTE PTR HPED_PCH, START_TENS
    MOV BYTE PTR HPED_PCL, START_UNITS
    ; show initial ped countdown on HPED_PORTC
    MOV AL, BYTE PTR HPED_PCH
    SHL AL, 4
    OR AL, BYTE PTR HPED_PCL
    MOV DX, HPED_PORTC
    OUT DX, AL
    RET

;=======================
;
; BROKEN! BROKEN! BROKEN! 
;
========================
PRINT_CHAR_VPED:
    PUSH SI
    PUSH CX

DISPLAY_LOOP_VPED:

    MOV CX, 8            ; scan 8 rows
    MOV DI, SI           ; DI = pointer to font data

ROW_SCAN_VPED:
    ;---- Select row ----
    MOV AL, 1
    SHL AL, CL           ; AL = 1 << (row#)
    OUT VPED_PORTA, AL   ; activate row

    ;---- Output row bits ----
    MOV AL, BYTE PTR CS:[DI]
    OUT VPED_PORTB, AL   ; send column pattern

    ;---- small hold time ----
    CALL SMALL_DELAY

    ;---- next row ----
    INC DI
    LOOP ROW_SCAN_VPED

    JMP DISPLAY_LOOP_VPED   ; keep showing character forever

    POP CX
    POP SI
    RET

    
 ;=======================
;
; BROKEN! BROKEN! BROKEN! 
;
========================   
PRINT_CHAR_HPED:
    PUSH SI
    PUSH CX

DISPLAY_LOOP_HPED:

    MOV CX, 8            ; scan 8 rows
    MOV DI, SI            

ROW_SCAN_HPED:
    ;---- Select row ----
    MOV AL, 1
    SHL AL, CL
    OUT HPED_PORTA, AL

    ;---- Output row bits ----
    MOV AL, BYTE PTR CS:[DI]
    OUT HPED_PORTB, AL

    ;---- small hold time ----
    CALL SMALL_DELAY

    INC DI
    LOOP ROW_SCAN_HPED

    JMP DISPLAY_LOOP_HPED   ; keep refreshing

    POP CX
    POP SI
    RET



; Non-blocking per-row refresh for vertical pedestrian display
REFRESH_VPED_ROW:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    ; get current row index
    MOV CL, BYTE PTR VPED_ROW
    ; select row (1 << row)
    MOV AL, 1
    SHL AL, CL
    MOV DX, VPED_PORTA
    OUT DX, AL
    ; output column bits from character ROM (NO_PED)
    MOV SI, OFFSET NO_PED
    ADD SI, CX
    MOV AL, BYTE PTR CS:[SI]
    MOV DX, VPED_PORTB
    OUT DX, AL
    CALL SMALL_DELAY
    ; update ped 7-seg with packed BCD PCH:PCL
    MOV AL, BYTE PTR VPED_PCH
    SHL AL, 4
    OR AL, BYTE PTR VPED_PCL
    MOV DX, VPED_PORTC
    OUT DX, AL
    ; advance row (wrap at 8)
    INC BYTE PTR VPED_ROW
    CMP BYTE PTR VPED_ROW, 8
    JL .rv_end
    MOV BYTE PTR VPED_ROW, 0
.rv_end:
    POP DX
    POP CX
    POP BX
    POP AX
    RET

; Non-blocking per-row refresh for horizontal pedestrian display
REFRESH_HPED_ROW:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CL, BYTE PTR HPED_ROW
    MOV AL, 1
    SHL AL, CL
    MOV DX, HPED_PORTA
    OUT DX, AL
    MOV SI, OFFSET NO_PED
    ADD SI, CX
    MOV AL, BYTE PTR CS:[SI]
    MOV DX, HPED_PORTB
    OUT DX, AL
    CALL SMALL_DELAY
    MOV AL, BYTE PTR HPED_PCH
    SHL AL, 4
    OR AL, BYTE PTR HPED_PCL
    MOV DX, HPED_PORTC
    OUT DX, AL
    INC BYTE PTR HPED_ROW
    CMP BYTE PTR HPED_ROW, 8
    JL .rh_end
    MOV BYTE PTR HPED_ROW, 0
.rh_end:
    POP DX
    POP CX
    POP BX
    POP AX
    RET

; Characters Data to display on 8x8 LED Matrix
NO_PED:
      DB 00111100B
      DB 00100100B
      DB 00011000B
      DB 01111110B
      DB 00011000B
      DB 00100100B
      DB 00100100B
      DB 01000010B
      
 PED_WAIT:
      DB 00011000B
      DB 00111100B
      DB 00111110B
      DB 10111111B
      DB 10111111B
      DB 10111111B
      DB 01111110B
      DB 00111100B

 PED_GO:
      DB 00111100B
      DB 00100100B
      DB 10011000B
      DB 01111110B
      DB 00011001B
      DB 01101000B
      DB 01000111B
      DB 01000000B

CODE ENDS
END START

