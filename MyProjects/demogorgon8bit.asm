        processor 6502
        include "vcs.h"
        include "macro.h"
        include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; We're going to set the player's coarse and fine position
; at the same time using a clever method.
; We divide the X coordinate by 15, in a loop that itself
; is 15 cycles long. When the loop exits, we are at
; the correct coarse position, and we set RESP0.
; The accumulator holds the remainder, which we convert
; into the fine position for the HMP0 register.
; This logic is in a subroutine called SetHorizPos.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteHeight	equ 26

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables segment

        seg.u Variables
	org $80

XPos		.byte
YPos		.byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment

	seg Code
        org $f000

Start
	CLEAN_START
        
        lda #80
        sta YPos
        sta XPos

NextFrame
        lsr SWCHB	; test Game Reset switch
        bcc Start	; reset?
; 1 + 3 lines of VSYNC
	VERTICAL_SYNC
; 37 lines of underscan
	TIMER_SETUP 37
; move X and Y coordinates w/ joystick
	jsr MoveJoystick
; the next two scanlines
; position the player horizontally
	lda XPos	; get X coordinate
        ldx #0		; player 0
        jsr SetHorizPos	; set coarse offset
        sta WSYNC	; sync w/ scanline
        sta HMOVE	; apply fine offsets
; it's ok if we took an extra scanline because
; the PIA timer will always count 37 lines
; wait for end of underscan
        TIMER_WAIT
; 192 lines of frame
	ldx #192	; X = 192 scanlines
LVScan
	txa		; X -> A
        sec		; set carry for subtract
        sbc YPos	; local coordinate
        cmp #SpriteHeight ; in sprite?
        bcc InSprite	; yes, skip over next
        lda #0		; not in sprite, load 0
InSprite
	tay		; local coord -> Y
        lda Frame0,y	; lookup color
        sta WSYNC	; sync w/ scanline
        sta GRP0	; store bitmap
        lda ColorFrame0,y ; lookup color
        sta COLUP0	; store color
        dex		; decrement X
        bne LVScan	; repeat until 192 lines

; 29 lines of overscan
	TIMER_SETUP 29
        TIMER_WAIT
; total = 262 lines, go to next frame
        jmp NextFrame

; SetHorizPos routine
; A = X coordinate
; X = player number (0 or 1)
SetHorizPos
	sta WSYNC	; start a new line
    SLEEP 3 
	sec		; set carry flag
DivideLoop
	sbc #15		; subtract 15
	bcs DivideLoop	; branch until negative
	eor #7		; calculate fine offset
	asl
	asl
	asl
	asl
	sta RESP0,x	; fix coarse position
	sta HMP0,x	; set fine offset
	rts		; return to caller

; Read joystick movement and apply to object 0
MoveJoystick
; Move vertically
; (up and down are actually reversed since ypos starts at bottom)
	ldx YPos
	lda #%00100000	;Up?
	bit SWCHA
	bne SkipMoveUp
        cpx #2
        bcc SkipMoveUp
        dex
SkipMoveUp
	lda #%00010000	;Down?
	bit SWCHA 
	bne SkipMoveDown
        cpx #183
        bcs SkipMoveDown
        inx
SkipMoveDown
	stx YPos
; Move horizontally
        ldx XPos
	lda #%01000000	;Left?
	bit SWCHA
	bne SkipMoveLeft
        cpx #16
        bcc SkipMoveLeft
        dex
SkipMoveLeft
	lda #%10000000	;Right?
	bit SWCHA 
	bne SkipMoveRight
        cpx #153
        bcs SkipMoveRight
        inx
SkipMoveRight
	stx XPos
	rts


; Cat-head graphics data
Frame0
        .byte #0        ; zero padding, also clears register
        .byte #%11000110
        .byte #%01101100
        .byte #%00101000
        .byte #%00101000
        .byte #%00101000
        .byte #%10101010
        .byte #%10101010
        .byte #%10101010
        .byte #%10111010
        .byte #%10111010
        .byte #%10111010
        .byte #%10111010
        .byte #%11111110
        .byte #%01111100
        .byte #%00010000
        .byte #%01101100
        .byte #%00101000
        .byte #%00010000
        .byte #%00101000
        .byte #%01000100
        .byte #%11000110
        .byte #%00101000
        .byte #%00010000
        .byte #%00010000

; Cat-head color data
ColorFrame0
        .byte #0        ; unused (for now)
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$0A
        .byte #$45
        .byte #$45
        .byte #$45
        .byte #$45
        .byte #$45
        .byte #$45
        .byte #$45
        .byte #$45
        .byte #$45
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Epilogue

	org $fffc
        .word Start	; reset vector
        .word Start	; BRK vector
