    processor 6502
    
    include "../utils/vcs.h"
    include "../utils/macro.h"

    seg code
    org $F000                 ; Code origin starts from F000 (Cartridge origin)

RESET:
    CLEAN_START               ; Macro to clear the Zero-Page
    
    ldx #$20                  ; Color code for Dark Orange
    stx COLUBK                ; Set BK color
    
    ldx #$1C                  ; Color code for Light Yellow
    stx COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the new frame by turning on VBLANK and VSYNC     ;;
;; Then render 3 lines for VSYNC and 37 lines for VBLANK  ;;
;; Following the WSYNC for 3 + 37 lines turn of both      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FRAME:
    lda #2                    ; Load 00000010 to register A
    sta VBLANK                ; Turn on VBLANK by loading 00000010 to special memory address on TIA
    sta VSYNC                 ; Turn on  VSYNC by loading 00000010 to special memory address on TIA
    lda #0

    REPEAT 3
        sta WSYNC             ; Three scanlines for VSYNC
    REPEND
    sta VSYNC                 ; Turn off VSYNC

    REPEAT 37
        sta WSYNC             ; 37 scanlines for VBLANK
    REPEND
    sta VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the CTRLPF register D0 (Mirror/Reflect) to 1    ;;
;; This will allow the playfield to symmeyric          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #%00000001   ; D0 (Least significant digit) will be 1
    stx CTRLPF       ; Set the CTRLPF register to mirror the scene

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render the playfield scanlines with the following pattern ;;
;; Render a frame with 7 lines thickness and offset 7 pixel  ;; 
;; From all directions inside equally                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Skip the first 7 scanlines with only BK
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND
    ; Set the next 7 scanlines with 1110 as PF0 and 1111 1111 as PF1 and PF2
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 14
        sta WSYNC
    REPEND
    ; Set the next 164 lines with 0010 as PF0 and 0000 0000 as PF1 and PF2
    ldx #%01100000
    stx PF0
    ldx #0
    stx PF1
    ldx #%10000000
    stx PF2
    REPEAT 150
        sta WSYNC
    REPEND
    ; Set the 7 lines before the last with 1110 as PF0 and 1111 1111 as PF1 and PF2
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    REPEAT 14
        sta WSYNC
    REPEND
    ; Set the last 7 scanlines with only BK
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set VBLANK on again and render final 30 overscan lines     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK
    lda #0

    REPEAT 30
        sta WSYNC
    REPEND
    sta VBLANK

    jmp FRAME

;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word RESET ; Reset vector
    .word RESET ; Interrupt vector (Unused in VCS)