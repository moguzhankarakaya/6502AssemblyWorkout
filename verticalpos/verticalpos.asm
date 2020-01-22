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
P0Pos    byte           ; define one byte for P0 position

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
    ldx #180                  ; Intial value for player 0 position
    stx P0Pos                 ; Initialize player 0 position as 180

    ldx #9                    ; Constant value for player 0 height
    stx P0Height              ; Set player 0 height as 9

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

    REPEAT 37
        sta WSYNC             ; 37 scanlines for VBLANK
    REPEND
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render the playfield                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #192                 ; Initialize the counter with 192
Scanline:
    txa                      ; Transfer x to accumulator
    sec                      ; Set carry flag
    sbc P0Pos                ; Accumulator -= P0Pos
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
    
    dec P0Pos

    jmp FRAME

;;;;;;;;;;;;;
;; GRAPICS ;;
;;;;;;;;;;;;;
    org $FFE8
PlayerBitMap:
    .byte #%00000000
    .byte #%00101000  
    .byte #%01110100  
    .byte #%11111010  
    .byte #%11111010  
    .byte #%11111010  
    .byte #%11111110  
    .byte #%01101100  
    .byte #%00110000
    
PlayerColor:
    .byte #$00
    .byte #$40  
    .byte #$40  
    .byte #$40  
    .byte #$40  
    .byte #$42  
    .byte #$42  
    .byte #$44  
    .byte #$D2  
    
;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word RESET ; Reset vector
    .word RESET ; Interrupt vector (Unused in VCS)