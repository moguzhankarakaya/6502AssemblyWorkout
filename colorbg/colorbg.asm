    processor 6502
    
    include "../utils/vcs.h"
    include "../utils/macro.h"

    seg code
    org $F000                 ; Code origin starts from F000 (Cartridge origin)

START:
    CLEAN_START               ; Macro to clear Zero-Page states

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SET BACKGROUND LUMINOSITY COLOR TO YELLOW  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETBG:
    lda #$1E                   ; Load color into A (NTSC yellow)
    sta COLUBK                 ; Store the color in a to Address $09

    jmp SETBG                  ; Repeat from START

;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word START ; Reset vector
    .word START ; Interrupt vector (Unused in VCS)