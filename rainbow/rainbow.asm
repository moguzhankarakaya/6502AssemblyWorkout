    processor 6502
    
    include "../utils/vcs.h"
    include "../utils/macro.h"

    seg code
    org $F000                 ; Code origin starts from F000 (Cartridge origin)

START:
    CLEAN_START               ; Macro to clear the Zero-Page

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start the new frame by turning on VBLANK and VSYNC  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FRAME:
    lda #2                    ; Load 00000010 to register A
    sta VBLANK                ; Turn on VBLANK by loading 00000010 to special memory address on TIA
    sta VSYNC                 ; Turn on VSYNC by loading 00000010 to special memory address on TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the first three scanlines as VSYNC         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    sta WSYNC
    sta WSYNC
    sta WSYNC                 ; First three scanlines

    lda #0
    sta VSYNC                 ; Turn off the VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the recommended 37 scanlines of VBLANK ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #37           ; Initialize loop counter as 37
LOOP_VBLANK:
    sta WSYNC         ; Wait for a scanline
    dex               ; x--
    bne LOOP_VBLANK   ; while (x > 0)

    lda #0
    sta VBLANK      ; Turn off the VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Start rendering 192 actual scanlines of the game frame  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #192
LOOP_FRAME_SCANLINES:
    stx COLUBK               ; Store the color in a to Address $09 of TIA
    sta WSYNC                ; Wait for scanline to be completed.
    dex                      ; x--
    bne LOOP_FRAME_SCANLINES ; while (x > 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   Start rendering 192 actual scanlines of the game frame  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2                   ; Activate hit register to turn on VBLANK
    sta VBLANK

    ldx #30                  ; Initialize loop counter as 30
LOOP_OVERSCAN:
    sta WSYNC                ; Wait for a scanline
    dex                      ; x--
    bne LOOP_OVERSCAN        ; while (x > 0)

    ;lda #0
    ;sta VBLANK      ; Turn off the VBLANK

    jmp FRAME       ; Start over

;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word START ; Reset vector
    .word START ; Interrupt vector (Unused in VCS)