; '2600 Stranger Things Title Screen

        processor 6502
        include "vcs.h"
        include "macro.h"

;-------------------------------------------------------------------------------
; Variable space allocation

        SEG.U vars
        ORG $80     ; start of RAM

glowCO ds 1         ; a 1-byte variable, controls color of PF
flag ds 1           ; a 1-byte variable, boolean truth flag

;-------------------------------------------------------------------------------
; Constants assignments

FPS = 8             ; speed of "glow animation" - change as desired

;--------------------------------------------------------------------------------

        SEG         ; end of uninitialized segment - start of ROM binary
        ORG $F000

Reset

; Clear RAM and all TIA registers

        ldx #0
        lda #0
Clear
        sta 0,x
        inx
        bne Clear

;--------------------------------------------------------------------------------
; Once-only initialization

        lda #$45
        sta COLUPF          ; set the playfield color

        sta glowCO          ; set the first playfield color in the variable

        ldy #0              ; "speed" counter
        sty flag            ; set boolean flag to false

;--------------------------------------------------------------------------------

StartOfFrame

; Start of new frame
; Start of vertical blank processing

        lda #0
        sta VBLANK

        lda #2
        sta VSYNC

        sta WSYNC
        sta WSYNC
        sta WSYNC           ; 3 scanlines of VSYNC signal

        lda #0
        sta VSYNC

;--------------------------------------------------------------------------------
; 37 scanlines of vertical blank

        ldx #0

VerticalBlank
        sta WSYNC
        inx
        cpx #37
        bne VerticalBlank

;-------------------------------------------------------------------------------
; Handle a change in the pattern once every 'FPS' frames

        iny             ; increment speed count by one
        cpy #FPS        ; has it reached our "change point"?
        bne Done        ; no, so branch past

        ldy #0          ; reset speed

        lda flag
        cmp #0          ; check if at lowest value
        bne pass1

        lda glowCO
        cmp #$40        ; check if at lowest value
        beq SetFlag

        dec glowCO      ; decrease PF color value by 1
        sta COLUPF
        jmp Done

SetFlag
        lda #1
        sta flag        ; set flag to true
        lda glowCO
        inc glowCO      ; increase PF color value by 1
        sta COLUPF
        jmp Done

pass1
        lda glowCO
        cmp #$48        ; check if at highest value
        beq ResetFlag

        inc glowCO      ; increase PF color value by 1
        sta COLUPF
        jmp Done

ResetFlag
        lda #0
        sta flag        ; set flag to false
        lda glowCO
        dec glowCO      ; decrease PF color value by 1
        sta COLUPF

Done

;--------------------------------------------------------------------------------
; Do 192 scanlines of picture

; Draw a blank image before start of letter

        ldx #0          ; this counts our scanline number

TopBlank
        sta WSYNC       ; wait until end of scanline
        inx             ; 2 cycles
        cpx #58         ; 2 cycles
        bne TopBlank    ; 2 cycles

;-------------------------------------------------------------------------------
; Draw the top bar

        lda #$80
        sta PF0         ; set PF0

        lda #$FF
        sta PF1         ; set PF1
        sta PF2         ; set PF2

        ldx #0
Bar1
        SLEEP 11
        lda #$FF
        sta PF0

        SLEEP 15
        lda #$0F
        sta PF2

        sta WSYNC
        lda #$FF
        sta PF2
        lda #$80
        sta PF0
        inx
        cpx #2
        bne Bar1

        lda #0          ; clear PF registers
        sta PF0
        sta PF1
        sta PF2
        sta CTRLPF      ; turn PF mirroring off
        ldx #0

        sta WSYNC
        sta WSYNC
        sta WSYNC
        sta WSYNC       ; create 4 scanline gap before start of text

;-------------------------------------------------------------------------------
; Draw the first 6 scanlines of 'Stranger'
        
        ldx #0          ; 2 cycles
scan1
        lda #0
        sta PF0         ; 3 cycles

        lda #$FD
        sta PF1         ; 3 cycles

        lda #$93
        sta PF2         ; 3 cycles

        SLEEP 13        ; wait for PF0a to display
        lda #$40        ; 2 cycles
        sta PF0         ; write to PF0b, 3 cycles

        SLEEP 8         ; wait for PF1a to display
        lda #$67        ; 2 cycles
        sta PF1         ; write to PF1b, 3 cycles

        SLEEP 2         ; wait for PF2a to display
        lda #$0F
        sta PF2         ; write to PF2b, 3 cycles

        sta WSYNC
        inx             ; 2 cycles
        cpx #6          ; 2 cycles
        bne scan1       ; 2 cycles skip, 3 taken

;-------------------------------------------------------------------------------
; Draw the first 2 scanlines of 'Stranger'

        ldx #0          ; 2 cycles
scan2
        lda #$80        ; 2 cycles
        sta PF0         ; 3 cycles

        lda #$C9        ; 2 cycles
        sta PF1         ; 3 cycles

        lda #$AA
        sta PF2         ; 3 cycles

        SLEEP 5         ; wait for PF0a to display
        lda #$40        ; 2 cycles
        sta PF0         ; 3 cycles

        SLEEP 6         ; wait for PF1a to display
        lda #$84        ; 2 cycles
        sta PF1         ; 3 cycles

        SLEEP 6         ; wait for PF2a to display
        lda #$0E        ; 2 cycles
        sta PF2         ; 3 cycles

        sta WSYNC
        inx             ; 2 cycles
        cpx #2          ; 2 cycles
        bne scan2       ; 2 cycles
;-------------------------------------------------------------------------------
; Draw the first 4 scanlines of 'Stranger'

        ldx #0          
scan3
        lda #$80       
        sta PF0       

        lda #$09        
        sta PF1        

        lda #$AA
        sta PF2        

        SLEEP 5
        lda #$40
        sta PF0

        SLEEP 6
        lda #$84
        sta PF1

        SLEEP 6
        lda #$0A
        sta PF2

        sta WSYNC
        inx
        cpx #4
        bne scan3

;-------------------------------------------------------------------------------
; Draw the second 4 scanlines of 'Stranger'

        ldx #0
scan4
        lda #$80
        sta PF0

        lda #$09
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$50
        sta PF0

        SLEEP 6
        lda #$B6
        sta PF1

        SLEEP 6
        lda #$0A
        sta PF2

        sta WSYNC
        inx
        cpx #4
        bne scan4

;-------------------------------------------------------------------------------
; Draw the second 2 scanlines for 'Stranger'

        ldx #0
scan5
        lda #$80
        sta PF0

        lda #$89
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$50
        sta PF0

        SLEEP 6
        lda #$B6
        sta PF1

        SLEEP 6
        lda #$06
        sta PF2

        sta WSYNC
        inx
        cpx #2
        bne scan5

;-------------------------------------------------------------------------------
; Draw the second 6 scanlines for 'Stranger'

        ldx #0
scan6
        lda #$80
        sta PF0

        lda #$89
        sta PF1

        lda #$BA
        sta PF2

        SLEEP 5
        lda #$60
        sta PF0

        SLEEP 6
        lda #$94
        sta PF1

        SLEEP 6
        lda #$06
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan6

;-------------------------------------------------------------------------------
; Draw the third 6 scanlines for 'Stranger'

        ldx #0
scan7
        lda #0
        sta PF0

        lda #$49
        sta PF1

        lda #$AA
        sta PF2

        SLEEP 5
        lda #$40
        sta PF0

        SLEEP 6
        lda #$67
        sta PF1

        SLEEP 6
        lda #$0A
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan7

;-------------------------------------------------------------------------------
; Draw the third 2 scanlines of 'Stranger'

        ldx #0
scan8
        lda #0
        sta PF0

        lda #$40
        sta PF1

        lda #0
        sta PF2

        SLEEP 5
        lda #0
        sta PF0

        SLEEP 6
        lda #0
        sta PF1

        SLEEP 6
        lda #$0A
        sta PF2

        sta WSYNC
        inx
        cpx #2
        bne scan8

;-------------------------------------------------------------------------------
; Draw the fourth 2 scanlines of 'Stranger'

        ldx #0
scan9
        lda #$80
        sta PF0

        lda #$C0
        sta PF1

        lda #0
        sta PF2

        SLEEP 5
        lda #0
        sta PF0

        SLEEP 6
        lda #0
        sta PF1

        SLEEP 6
        lda #$12
        sta PF2

        sta WSYNC
        inx
        cpx #2
        bne scan9

;-------------------------------------------------------------------------------
; Draw the fourth 6 scanlines for 'Stranger'

        ldx #0
scan10
        lda #$80
        sta PF0

        lda #$80
        sta PF1

        lda #0
        sta PF2

        SLEEP 5
        lda #0
        sta PF0

        SLEEP 6
        lda #0
        sta PF1

        SLEEP 6
        lda #$12
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan10

;-------------------------------------------------------------------------------
; Draw the first four scanlines for 'Things'

        ldx #0
scan11
        lda #0
        sta PF0

        lda #$0E
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$40
        sta PF0

        SLEEP 6
        lda #$67
        sta PF1

        SLEEP 6
        lda #0
        sta PF2

        sta WSYNC
        inx
        cpx #4
        bne scan11

;-------------------------------------------------------------------------------
; Draw the first 2 scanlines for 'Things'

        ldx #0
scan12
        lda #$80
        sta PF0

        lda #$EE
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$40
        sta PF0

        SLEEP 6
        lda #$67
        sta PF1

        SLEEP 6
        lda #$1E
        sta PF2

        sta WSYNC
        inx
        cpx #2
        bne scan12

;-------------------------------------------------------------------------------
; Draw the first 6 scanlines of 'Things'

        ldx #0
scan13
        lda #0
        sta PF0

        lda #$04
        sta PF1

        lda #$AF
        sta PF2

        SLEEP 5
        lda #$40
        sta PF0

        SLEEP 6
        lda #$84
        sta PF1

        SLEEP 6
        lda #0
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan13

;-------------------------------------------------------------------------------
; Draw the second 6 scanlines for 'Things'

        ldx #0
scan14
        lda #0
        sta PF0

        lda #$04
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$50
        sta PF0

        SLEEP 6
        lda #$B6
        sta PF1

        SLEEP 6
        lda #0
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan14

;-------------------------------------------------------------------------------
; Draw the third 6 scanlines for 'Things'

        ldx #0
scan15
        lda #0
        sta PF0

        lda #$04
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$60
        sta PF0

        SLEEP 6
        lda #$91
        sta PF1

        SLEEP 6
        lda #0
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan15

;-------------------------------------------------------------------------------
; Draw the last 6 scanlines of 'Things'

        ldx #0
scan16
        lda #0
        sta PF0

        lda #$04
        sta PF1

        lda #$A9
        sta PF2

        SLEEP 5
        lda #$40
        sta PF0

        SLEEP 6
        lda #$67
        sta PF1

        SLEEP 6
        lda #0
        sta PF2

        sta WSYNC
        inx
        cpx #6
        bne scan16

; Draw a blank image at bottom of characters

        lda #0          
        sta PF2         ; reset PF2
        sta PF1         ; reset PF1
        sta PF0         ; reset PF0
        sta CTRLPF      ; reset CTRLPF
        ldx #0

BotBlank
        sta WSYNC
        inx
        cpx #58
        bne BotBlank

;--------------------------------------------------------------------------------

        lda #%01000010
        sta VBLANK          ; end of screen - enter blanking

; 30 scanlines of overscan

        ldx #0
Overscan
        sta WSYNC
        inx
        cpx #30
        bne Overscan

        jmp StartOfFrame

;--------------------------------------------------------------------------------

        ORG $FFFA

InterruptVectors

        .word Reset         ; NMI
        .word Reset         ; RESET
        .word Reset         ; IRQ

        END

