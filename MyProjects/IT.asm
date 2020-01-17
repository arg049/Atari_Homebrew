        processor 6502
        include "vcs.h"
        include "macro.h"

        seg.u Variables
        org $80

Temp            byte
LoopCount       byte

THREE_COPIES    equ %011

        seg Code
        org $F000

Start
        CLEAN_START

NextFrame
        VERTICAL_SYNC

        TIMER_SETUP 37
        lda #66
        sta LoopCount       ; scanline counter
        lda #$44
        sta COLUP0          
        sta COLUP1          ; set player colors
        lda #THREE_COPIES
        sta NUSIZ0
        sta NUSIZ1          ; both players have 3 copies
        ldx #0
        lda #56
        jsr SetHorizPos
        ldx #1
        lda #64
        jsr SetHorizPos
        sta WSYNC
        sta HMOVE           ; apply HMOVE
        lda #1
        sta VDELP0          ; we need the VDEL registers
        sta VDELP1          ; so we can do our 4-store trick
        TIMER_WAIT

        TIMER_SETUP 63
        TIMER_WAIT

        TIMER_SETUP 129

        SLEEP 57            ; start near end of scanline
BigLoop
        ldy LoopCount       ; counts backwards
        lda Bitmap0,y       ; load B0 (1st sprite byte)
        sta GRP0            ; B0 -> [GRP0]
        lda Bitmap1,y       ; load B1 -> A
        sta GRP1            ; B1 -> [GRP1], B0 -> GRP0
        lda Bitmap2,y       ; load B2 -> A
        sta GRP0            ; B2 -> [GRP0], B1 -> GRP1
        lda Bitmap5,y       ; load B5 -> A
        sta Temp            ; B5 -> Temp
        ldx Bitmap4,y       ; load B4 -> X
        lda Bitmap3,y       ; load B3 -> A
        ldy Temp            ; load B5 -> Y
        SLEEP 14
        sta GRP1            ; B3 -> [GRP1], B2 -> GRP0
        stx GRP0            ; B4 -> [GRP0], B3 -> GRP1
        sty GRP1            ; B5 -> [GRP1], B4 -> GRP0
        sta GRP0            ; ?? -> [GRP0], B5 -> GRP1
        dec LoopCount       ; go to next line
        bpl BigLoop

        TIMER_WAIT

        TIMER_SETUP 29
        TIMER_WAIT
        jmp NextFrame

        align $100          ; ensure we start on a page boundary
Bitmap0
        hex 00
        hex 67FFFF7F3F1F1F1F1F1F1F1F071F
        hex 1F1F1F1F1F1F1F1F1F0F1F1F0F
        hex 1F1F0F03031F1F1F0B071F1F1F
        hex 1F1F1F0F1F1F1F0F1F1F1F1F0F
        hex 1F1F1F1F1F1F3FFFFFFFC60000
Bitmap1
        hex 00
        hex 77FFFFFFFFFFFFFFFFFFFFFFFFFE
        hex FEFEFEFEFEFEFEFEFEFFFFFFFF
        hex FFFFF9F9F8F8FAF9FFFDF9F9FF
        hex FFFFFFFFFFFEFFFFFFFFFFFFFF
        hex FEFEFEFCFCFEFFFFFFFFFF0400
Bitmap2
        hex 00
        hex 60E0E0E0C0808080808080000000
        hex 80800000000000000000000000
        hex 00000000000000000000000000
        hex 00000004050F0F070707070707
        hex 07070707070787C7E7E7E30306

        align $100
Bitmap3
        hex 00
        hex 00FFFFFF7F1F070F0F0F030F0F0F
        hex 0F0F07070F070F0F0F0F0D0007
        hex 0707070707070707070F0F0F0F
        hex 0F0F0F0F0F0F0F0F0F8F8F8F8F
        hex 8F8FCFCFCFCFEFFFFFFFFFE310
Bitmap4
        hex 00
        hex 03FFFFFFFFFFFEFEFFFFFFFFFFFF
        hex FFFFFFFFFFFFFFFFFFFFFF7F7F
        hex FFFFFFFFFFFFFFFFFFFFFFFFFF
        hex FFFFFFFFFFFFFFFFFFFFFFFFFF
        hex FFFFFFFFFFFFFFFFFFFFFFFF00
Bitmap5
        hex 00
        hex C0F8F8F8F8200000008080808080
        hex 80808000808080808080808080
        hex 80808080808000808080000080
        hex 80800000838387878786878F8F
        hex 8F9F9F9F87B7FFFFFFFFFFFF43

SetHorizPos
        sta WSYNC
        SLEEP 3
        sec
DivideLoop
        sbc #15
        bcs DivideLoop
        eor #7
        asl
        asl
        asl
        asl
        sta RESP0,x
        sta HMP0,x
        rts

        org $FFFC
        .word Start
        .word Start
