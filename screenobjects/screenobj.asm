    processor 6502
    
    include "../utils/vcs.h"
    include "../utils/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start and uninitialized segment at                  ;; 
;; $80 for variable decleration                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
SBHeight ds 1           ; define one byte for Scoreboard
P0Height ds 1           ; define one byte for P0 height
P1Height ds 1           ; define one byte for P1 height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start of the ROM code segment                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg Code
    org $F000                 ; Code origin starts from F000 (Cartridge origin)

RESET:
    CLEAN_START               ; Macro to clear the Zero-Page
    
    ldx #$AF                  ; Color code for Yellow
    stx COLUBK                ; Set BK color
    
    ldx #%1111                ; Color code for White
    stx COLUPF                ; Set Playfield color

    ldx #$48                  ; Color code for red
    stx COLUP0                ; Set Player 0 color

    ldx #$C6                  ; Color code for green
    stx COLUP1

    ldx #10                   ; Register A <- 10
    stx SBHeight              ; SBHeight <- 10
    stx P0Height              ; P0Height <- 10
    stx P1Height              ; P1Height <- 10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the CTRLPF register D0 (Mirror/Reflect) to 1    ;;
;; This will allow the playfield to symmeyric          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #%00000010   ; D1 Means Score
    stx CTRLPF       ; Set the CTRLPF to set scoreboard color according to plyer color

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render the playfield scanlines with scoreboard of two players ;;
;; Render two players                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Skip the first 10 scanlines with only BK
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 10
        sta WSYNC
    REPEND

    ldy #0
LoopScoreboard:       ; Render scoreboard for 10 scanlines
    lda NumberTwoBitMap,Y
    sta PF1
    sta WSYNC
    iny
    cpy SBHeight
    bne LoopScoreboard
    lda #0
    sta PF1           ; Reset PF registers to zero

    
    REPEAT 50
        sta WSYNC     ; Render 50 empty scanlines
    REPEND

    
    ldy #0
LoopPlayer0:          ; Render player 0
    lda PlayerBitMap,Y
    sta GRP0
    sta WSYNC
    iny
    cpy P0Height
    bne LoopPlayer0
    lda #0
    sta GRP0          ; Disable Player 0 Graphics

    ldy #0
LoopPlayer1:          ; Render player 1
    lda PlayerBitMap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy P1Height
    bne LoopPlayer1
    lda #0
    sta GRP1          ; Disable Player 1 Graphics


    REPEAT 102
        sta WSYNC     ; Render remaining 102 empty scanlines
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

;;;;;;;;;;;;;
;; GRAPICS ;;
;;;;;;;;;;;;;
    org $FFE8
PlayerBitMap:
    .byte #%01111110  ;  ######
    .byte #%11111111  ; ########
    .byte #%10011001  ; #  ##  #
    .byte #%11111111  ; ########
    .byte #%11111111  ; ########
    .byte #%11111111  ; ########
    .byte #%10111101  ; # #### #
    .byte #%11000011  ; ##    ##
    .byte #%11111111  ; ########
    .byte #%01111110  ;  ######
    
    org $FFF2
NumberTwoBitMap:
    .byte #%00001110  ; #########
    .byte #%00001110  ; #########
    .byte #%00000010  ;       ###
    .byte #%00000010  ;       ###
    .byte #%00001110  ; #########
    .byte #%00001110  ; #########
    .byte #%00001000  ; ###
    .byte #%00001000  ; ###
    .byte #%00001110  ; #########
    .byte #%00001110  ; #########
    
;;;;;;;;;;;;;;;;;;;;
;;  FILL THE ROM  ;;
;;;;;;;;;;;;;;;;;;;;

    org $FFFC   ; Defines the origin $FFFC
    .word RESET ; Reset vector
    .word RESET ; Interrupt vector (Unused in VCS)