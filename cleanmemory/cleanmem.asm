    processor 6502
    seg code
    org $F000     ; define the code origin at $F000

Start:
    sei           ; disable interrupts
    cld           ; disable the BCD decimal math mode
    ldx #$FF      ; loads the register with #$FF
    txs           ; transfer X register to S(tack) register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear the Zero Page region ($00 to $FF)             ;;
;; Meaning the entire TIA register space and also RAM  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #$10      ; Register A <-- 0
    ldx #$FF      ; Register X <-- #$FF
    sta $FF
MemLoop:
    dex           ; x--
    sta $0,X      ; store zero at address $0 + X
    bne MemLoop   ; do while X > 0 (z-flag set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill ROM size to exaclty 4KB           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC
    .word Start    ; reset vector at $FFFC (where program starts)
    .word Start    ; interrrupt vector at $FFFE (unused in VCS)