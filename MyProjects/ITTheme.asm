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

Trk0idx		equ	$e0	; offset into tracks for channel 0
Trk1idx		equ	$e1	; offset into tracks for channel 1
Pat0idx		equ	$e2	; offset into patterns for channel 0
Pat1idx		equ	$e3	; offset into patterns for channel 1
Chan0dur	equ	$e4	; current note duration channel 0
Chan1dur	equ	$e5	; current note duration channel 1
Chan0note	equ	$e6	; current note pitch channel 0
Chan1note	equ	$e7	; current note pitch channel 1

; Usage: NOTE pitch duration
; Plays a note in a pattern.
; pitch = 0-31
; duration = 1-7, uses DurFrames lookup table
	MAC NOTE
.pitch	SET {1}
.durat	SET {2}
	.byte (.pitch+(.durat<<5))
        ENDM

; Usage: TONE tone
; Changes the tone in a pattern.
; tone = 1-15
	MAC TONE
.tone	SET {1}
	.byte .tone
        ENDM

; Usage: PATTERN address
; Plays a pattern in a track.
	MAC PATTERN
.addr	SET {1}
	.byte (.addr-Patterns)
        ENDM

; Usage: ENDTRACK
; Marks the end of a track.
        MAC ENDTRACK
        .byte 0
        ENDM

Start
        CLEAN_START
        jsr ResetTrack

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

        ldx #0
        jsr MusicFrame
        ldx #1
        jsr MusicFrame
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

ResetTrack
	lda #0
        sta Trk0idx
        sta Pat0idx
        sta Pat1idx
        sta Chan0dur
        sta Chan1dur
        lda #Track1-Track0
        sta Trk1idx
NextPattern
	ldy Trk0idx,x
	lda Track0,y
        beq ResetTrack
        sta Pat0idx,x
        inc Trk0idx,x
MusicFrame
	dec Chan0dur,x		; decrement note duration
        bpl PlayNote		; only load if duration < 0
TryAgain
	ldy Pat0idx,x		; load index into pattern table
	lda Patterns,y		; load pattern code
        beq NextPattern		; end of pattern?
        inc Pat0idx,x		; increment pattern index for next time
        pha			; save A for later
        clc			; clear carry for ROL
        rol
        rol
        rol
        rol			; rotate A left by 4 (same as ROR by 5)
        and #7			; only take top 3 bits
        beq NoteTone		; duration zero? tone instruction
        tay			; Y = duration
        lda DurFrames,y		; look up in duration table
        sta Chan0dur,x		; save note duration
        pla			; pop saved value into A
        and #$1f		; extract first 5 bits
        sta Chan0note,x		; store as note value
PlayNote
	lda Chan0note,x		; get note pitch for channel
	sta AUDF0,x		; store frequency register
    lda #8
	sta AUDV0,x		; store volume register
	rts
; This routine is called for duration 0 (TONE) codes
NoteTone
	pla
        and #$f
        beq NextPattern
        sta AUDC0,x
        jmp TryAgain


Patterns
	TONE 0		; byte 0 of patterns array is unused

Pattern00
	    TONE 6
	    NOTE 9,7
        TONE 12
        NOTE 24,4
        NOTE 24,1
        NOTE 21,4
        NOTE 21,1
        TONE 6
        NOTE 3,6
        NOTE 3,2
        TONE 12
        NOTE 31,6
        NOTE 31,2
        TONE 0

Pattern01
        TONE 6
        NOTE 7,7
        NOTE 7,7
        NOTE 7,7
        NOTE 7,5
        TONE 0

Pattern02
        TONE 6
        NOTE 3,7
        NOTE 3,6
        NOTE 3,1
        TONE 12
        NOTE 25,7
        NOTE 25,6
        NOTE 25,1
        TONE 0

Pattern03
        TONE 12
        NOTE 28,7
        NOTE 20,4
        NOTE 20,1
        NOTE 18,4
        NOTE 18,1
        NOTE 17,6
        NOTE 17,2
        NOTE 15,6
        NOTE 15,2
        TONE 0

Pattern04
        TONE 12
        NOTE 26,7
        NOTE 26,7
        NOTE 26,7
        NOTE 26,5
        TONE 0

Pattern05
        TONE 4
        NOTE 31,7
        NOTE 31,6
        NOTE 31,1
        TONE 12
        NOTE 15,7
        NOTE 15,6
        NOTE 15,1
        TONE 0

Pattern06
        TONE 6
        NOTE 9,7
        TONE 12
        NOTE 15,4
        NOTE 15,1
        NOTE 16,4
        NOTE 16,1
        NOTE 18,6
        NOTE 18,2
        TONE 6
        NOTE 4,6
        NOTE 4,2
        TONE 0

Pattern07
        TONE 6
        NOTE 8,6
        NOTE 8,3
        TONE 12
        NOTE 22,3
        NOTE 22,2
        TONE 6
        NOTE 4,3
        NOTE 4,2
        TONE 12
        NOTE 28,7
        NOTE 28,6
        NOTE 28,1
        TONE 0

Pattern08
	    TONE 12
	    NOTE 30,7
        NOTE 18,4
        NOTE 18,1
        NOTE 16,4
        NOTE 16,1
        NOTE 15,6
        NOTE 15,2
        NOTE 24,6
        NOTE 24,2
        TONE 0

Pattern09
        TONE 6
        NOTE 10,4
        NOTE 10,1
        TONE 12
        NOTE 27,4
        NOTE 27,1
        NOTE 24,4
        NOTE 24,1
        NOTE 21,5
        TONE 6
        NOTE 3,4
        NOTE 3,1
        TONE 12
        NOTE 17,4
        NOTE 17,1
        NOTE 16,4
        NOTE 16,1
        NOTE 14,5
        TONE 0

Pattern10
        TONE 12
        NOTE 12,6
        NOTE 12,6
        NOTE 14,3
        NOTE 14,2
        NOTE 16,3
        NOTE 16,2
        NOTE 17,7
        NOTE 17,6
        NOTE 17,1
        TONE 0

Pattern11
        TONE 6
        NOTE 11,6
        NOTE 11,3
        TONE 12
        NOTE 14,3
        NOTE 14,2
        NOTE 16,3
        NOTE 16,2
        NOTE 17,7
        NOTE 17,6
        NOTE 17,1
        TONE 0

Pattern12
        TONE 6
        NOTE 9,6
        TONE 12
        NOTE 16,3
        NOTE 17,4
        NOTE 17,1
        NOTE 19,4
        NOTE 19,1
        NOTE 20,4
        NOTE 20,1
        NOTE 19,4
        NOTE 19,1
        NOTE 17,4
        NOTE 17,1
        NOTE 16,5
        TONE 0

Pattern13
        TONE 6
        NOTE 11,7
        NOTE 11,4
        TONE 12
        NOTE 16,4
        NOTE 16,1
        NOTE 18,4
        NOTE 18,1
        NOTE 19,7
        NOTE 19,4
        TONE 0

Pattern14
        TONE 12
        NOTE 15,7
        NOTE 15,4
        NOTE 16,4
        NOTE 16,1
        NOTE 18,4
        NOTE 18,1
        NOTE 19,7
        NOTE 19,4
        TONE 0

Pattern15
        TONE 6
        NOTE 8,6
        TONE 12
        NOTE 10,2
        TONE 4
        NOTE 30,7
        NOTE 30,6
        NOTE 30,2
        NOTE 23,2
        TONE 12
        NOTE 10,6
        TONE 0

Pattern16
        TONE 6
        NOTE 8,6
        TONE 12
        NOTE 10,2
        TONE 4
        NOTE 30,7
        NOTE 30,6
        NOTE 30,2
        NOTE 25,2
        TONE 12
        NOTE 10,6
        TONE 0

Pattern17
        TONE 6
        NOTE 12,6
        TONE 12
        NOTE 10,2
        TONE 4
        NOTE 30,7
        NOTE 30,7
        NOTE 0,7
        NOTE 0,7
        NOTE 0,7
        NOTE 0,7
        TONE 0

Pattern18
        ;TONE 6
        ;NOTE 12,7
        ;NOTE 12,7
        ;NOTE 12,7
        ;NOTE 12,5
        ;TONE 4
        ;NOTE 0,7
        ;NOTE 0,7
        ;NOTE 0,7
        ;NOTE 0,5
        ;TONE 0

Track0
	PATTERN Pattern00
	PATTERN Pattern01
	PATTERN Pattern03
	PATTERN Pattern04
	PATTERN Pattern06
	PATTERN Pattern07
	PATTERN Pattern08
	PATTERN Pattern09
	PATTERN Pattern10
	PATTERN Pattern12
	PATTERN Pattern13
	PATTERN Pattern15
	PATTERN Pattern16
	PATTERN Pattern17
	;PATTERN Pattern18
        ENDTRACK
Track1
	PATTERN Pattern00
	PATTERN Pattern02
	PATTERN Pattern03
	PATTERN Pattern05
	PATTERN Pattern06
	PATTERN Pattern07
	PATTERN Pattern08
	PATTERN Pattern09
	PATTERN Pattern11
	PATTERN Pattern12
	PATTERN Pattern14
	PATTERN Pattern15
	PATTERN Pattern16
	PATTERN Pattern17
	;PATTERN Pattern18
        ENDTRACK

DurFrames
	.byte 0,4,8,12,16,24,32,48

        org $FFFC
        .word Start
        .word Start
