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
        cpx #57         ; 2 cycles
        bne TopBlank    ; 2 cycles


;-------------------------------------------------------------------------------
; Draw the Stranger Things logo

        inx
ScanLoop
        sta WSYNC
        lda PFBitmap0-58,x
        sta PF0         ; store first playfield byte
        lda PFBitmap1-58,x
        sta PF1         ; store 2nd byte
        lda PFBitmap2-58,x
        sta PF2         ; store 3rd byte

        SLEEP 8         ; pause to let pf finish drawing

        lda PFBitmap3-58,x
        sta PF0         ; store 4th byte
        lda PFBitmap4-58,x
        sta PF1         ; store 5th byte
        lda PFBitmap5-58,x
        sta PF2         ; store 6th byte
        
        inx
        cpx #134
        bne ScanLoop    ; repeat until all scanlines drawn


; Draw a blank image at bottom of characters

        lda #0          
        sta PF2         ; reset PF2
        sta PF1         ; reset PF1
        sta PF0         ; reset PF0
        sta CTRLPF      ; reset CTRLPF

BotBlank
        sta WSYNC
        inx
        cpx #193
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
; Bitmap data - Stranger Things Logo

PFBitmap0
        hex 808000000000000000000000
        hex 808080808080808080808080
        hex 808080808080000000000000
        hex 000080808080808080800000
        hex 000080800000000000000000
        hex 00000000000000000000000000000000
PFBitmap1
        hex FFFF00000000FDFDFDFDFDFD
        hex C9C909090909090909098989
        hex 898989898989494949494949
        hex 4040C0C08080808080800E0E
        hex 0E0EEEEE0404040404040404
        hex 04040404040404040404040404040404
PFBitmap2
        hex FFFF00000000939393939393
        hex AAAAAAAAAAAAA9A9A9A9A9A9
        hex BABABABABABAAAAAAAAAAAAA
        hex 00000000000000000000A9A9
        hex A9A9A9A9AFAFAFAFAFAFA9A9
        hex A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9A9
PFBitmap3
        hex FFFF00000000404040404040
        hex 404040404040505050505050
        hex 606060606060404040404040
        hex 000000000000000000004040
        hex 404040404040404040405050
        hex 50505050606060606060404040404040
PFBitmap4
        hex FFFF00000000676767676767
        hex 848484848484B6B6B6B6B6B6
        hex 949494949494676767676767
        hex 000000000000000000006767
        hex 67676767848484848484B6B6
        hex B6B6B6B6919191919191676767676767
PFBitmap5
        hex 0F0F000000000F0F0F0F0F0F
        hex 0E0E0A0A0A0A0A0A0A0A0606
        hex 0606060606060A0A0A0A0A0A
        hex 0A0A12121212121212120000
        hex 00001E1E0000000000000000
        hex 00000000000000000000000000000000

;--------------------------------------------------------------------------------

        ORG $FFFA

InterruptVectors

        .word Reset         ; NMI
        .word Reset         ; RESET
        .word Reset         ; IRQ

        END

