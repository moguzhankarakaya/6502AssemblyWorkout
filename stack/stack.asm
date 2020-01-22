    processor 6502
    
    include "../utils/vcs.h"
    include "../utils/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of the ROM code segment                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000                 ; Code origin starts from F000 (Cartridge origin)

RESET:
    CLEAN_START               ; Macro to clear the Zero-Page

STACK_EXERCISE:   
    ldx #$FF                  ; Initialize stack pointer
    txs                       ; Transfer x to stack pointer
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Push variables into the stack                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$6F
    pha
    sbc #1
    pha
    sbc #1
    pha
    sbc #1
    pha

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pull variables from stack to accumulator            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #$80
    pla
    sta 0,Y
    pla 
    sta 1,Y
    pla 
    sta 2,Y
    pla 
    sta 3,Y

    jmp STACK_EXERCISE
;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word RESET ; Reset vector
    .word RESET ; Interrupt vector (Unused in VCS)