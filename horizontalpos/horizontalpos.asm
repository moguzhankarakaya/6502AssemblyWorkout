    processor 6502
    
    include "../utils/vcs.h"
    include "../utils/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start and uninitialized segment at                  ;; 
;; $80 for variable decleration                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
P0Height byte           ; define one byte for P0 height
P0YPos   byte           ; define one byte for P0 Y position
P0XPos   byte           ; define one byte for P0 X position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of the ROM code segment                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000                 ; Code origin starts from F000 (Cartridge origin)

RESET:
    CLEAN_START               ; Macro to clear the Zero-Page
    
    ldx #$00                  ; Color code for Yellow
    stx COLUBK                ; Set BK color

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variable Initialization                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #130                   ; Intial value for player 0 Y position
    stx P0YPos                 ; Initialize player 0 position as 180

    ldx #0                     ; Intial value for player 0 X position
    stx P0XPos                 ; Initialize player 0 position as 50

    ldx #9                     ; Constant value for player 0 height
    stx P0Height               ; Set player 0 height as 9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the new frame by turning on VBLANK and VSYNC     ;;
;; Then render 3 lines for VSYNC and 37 lines for VBLANK  ;;
;; Following the WSYNC for 3 + 37 lines turn of both      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FRAME:
    lda #2                    ; Load 00000010 to register A
    sta VSYNC                 ; Turn on  VSYNC by loading 00000010 to special memory address on TIA
    sta VBLANK                ; Turn on VBLANK by loading 00000010 to special memory address on TIA
    lda #0

    REPEAT 3
        sta WSYNC             ; Three scanlines for VSYNC
    REPEND
    sta VSYNC                 ; Turn off VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Calculate P0 X Position                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda P0XPos                ; Load register A with X Position of P0 sprite
    and #$7F                  ; (AND) register A with 0111 1111
                              ; to keep the most significant bit zero
    sta WSYNC                 ; Wait for the scanline
    sta HMCLR                 ; Clear old horizontal position values

    sec                       ; Set carry flag
DIVIDE:
    sbc #15                   ; A -= 15
    bcs DIVIDE                ; While A > 15 cont. substraction

    eor #7                    ; Map last 4 bits of acc. between -8 and 7
    asl
    asl
    asl
    asl                       ; Shift bytes in register A 4 times.
    sta HMP0
    sta RESP0
    sta WSYNC
    sta HMOVE

    REPEAT 37
        sta WSYNC             ; 37 scanlines for VBLANK
    REPEND
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render the playfield                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    REPEAT 6
        sta WSYNC
    REPEND

    ldx #180                 ; Initialize the counter with 192
Scanline:
    txa                      ; Transfer x to accumulator
    sec                      ; Set carry flag
    sbc P0YPos               ; Accumulator -= P0Pos
    cmp P0Height             ; [(LoopCounter - P0Pos) < P0Height] -> comperison
    bcc Loadbitmap           ; if comperison is True -> Go to Load Bit Map routine
    lda #0                   ; else                  -> Set accumulator to 0

Loadbitmap:
    tay                      ; Transfer a to y
    lda PlayerBitMap,Y       ; load player bitmap slice of data
    sta WSYNC                ; wait for next scanline
    sta GRP0                 ; set graphics for player 0 slice
    lda PlayerColor,Y        ; load player color from lookup table
    sta COLUP0               ; set color for player 0 slice

    dex
    bne Scanline   ; repeat next scanline until finished

    lda #0
    sta GRP0
    sta COLUP0  

    REPEAT 6
        sta WSYNC
    REPEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set VBLANK on again and render final 30 overscan lines     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Overscan:
    lda #2
    sta VBLANK
    lda #0

    REPEAT 30
        sta WSYNC
    REPEND
    sta VBLANK
    
    dec P0YPos
    
    jmp FRAME

;;;;;;;;;;;;;
;; GRAPICS ;;
;;;;;;;;;;;;;
    org $FFE8
PlayerBitMap:
    byte #%00000000
    .byte #%00000000;$50
    .byte #%01011101;$AE
    .byte #%01010101;$8C
    .byte #%01010101;$98
    .byte #%01010101;$74
    .byte #%01010111;$82
    .byte #%11110111;$80
    .byte #%00000000;$00
    
PlayerColor:
    byte #$00
    byte #$00;
    byte #$AE;
    byte #$8C;
    byte #$98;
    byte #$74;
    byte #$82;
    byte #$80;
    byte #$00;

    
;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word RESET ; Reset vector
    .word RESET ; Interrupt vector (Unused in VCS)