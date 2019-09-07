        processor 6502
        include "vcs.h"
        include "macro.h"

;-------------------------------------------------------------------------------
; Define/assign constant variables

PHeight     = 16
BlHeight    = 4
P0XPos      = 20
P1XPos      = 149
BlStart     = 80

;-------------------------------------------------------------------------------
; Define RAM variables

        seg.u Variables
        org $80

YBall       ds 1
YBallVel    ds 1
XBallVel    ds 1
YPos0       ds 1
YPos1       ds 1
Paddle0     ds 1
Paddle1     ds 1
P0Temp      ds 1
P1Temp      ds 1
XBall       ds 1
Temp        ds 1
BFlag       ds 1
Lasthit     ds 1

;-------------------------------------------------------------------------------
; Set up macros

        MAC READ_PADDLES
        lda INPT0,y
        bpl .save
        .byte $2c
.save   stx Paddle0,y

        ENDM

        MAC DRAW_BALL
        txa
        sec
        sbc YBall
        cmp #BlHeight
        lda #$00
        bcs .noball
        lda #$02
.noball
        sta ENABL
        ENDM

;-------------------------------------------------------------------------------
; Code segment

        seg Code
        org $F000

Start
        CLEAN_START

        lda #1
        sta BFlag

        lda #$94
        sta COLUBK

        lda #80
        sta YPos0
        sta YPos1
        sta YBall
        lda #$45
        sta COLUP0
        sta COLUP1
        lda #$08
        sta COLUPF

        ; set ball horizontal position
        lda #BlStart
        sta XBall
        ldx #4
        jsr SetHorizPos
        ;sta WSYNC       ; sync w/ scanline
        ;sta HMOVE       ; apply fine offsets

        ; set ball initial velocity
        lda #$FF
        sta YBallVel
        sta XBallVel

        ; set ball thickness
        lda #$10
        sta CTRLPF

        lda #$01
        sta VDELP0

NextFrame
        lsr SWCHB       ; test Game Reset switch
        bcc Start       ; reset?

        VERTICAL_SYNC
        lda #$82
        sta VBLANK      ; turn off video, dump paddles to ground

        TIMER_SETUP 37
        ; set player horizontal positions
        lda #P0XPos      ; get X coordinate
        ldx #0          ; player 0
        jsr SetHorizPos ; set coarse offset
        lda #P1XPos
        ldx #1
        jsr SetHorizPos
        ;sta WSYNC
        ;sta HMOVE
        TIMER_WAIT

        lda #0
        sta VBLANK      ; turn on display

        ; Draw the top wall
        lda #$FF
        sta PF0
        sta PF1
        sta PF2         ; straight line PF

        ldx #188
        stx Paddle0
        stx Paddle1
.toploop
        sta WSYNC
        lda BFlag
        beq skipb1
        DRAW_BALL
skipb1
        dex
        cpx #162;#182
        bne .toploop

        ; turn off PF
        sta WSYNC
        lda #0
        sta PF0
        sta PF1
        sta PF2

        ; Draw players/ball
LVScan
        txa             ; X -> A
        sec             ; set carry for subtract
        sbc YPos0       ; local coordinate
        ldy #$F0
        cmp #PHeight    ; in sprite?
        bcc Player1     ; yes, skip over next
        ldy #0          ; not in sprite, load 0
Player1
        sty GRP0
        txa
        sec
        sbc YPos1
        ldy #$F0
        cmp #PHeight
        bcc InSprite
        ldy #0
        
InSprite
        sta WSYNC
        sty GRP1

        lda BFlag
        beq skipb2
        DRAW_BALL
skipb2
        ldy #0
        READ_PADDLES
        ldy #1
        READ_PADDLES
        dex
        sta WSYNC

        lda BFlag
        beq skipb3
        DRAW_BALL
skipb3
        dex
        cpx #6
        bne LVScan

        ; Draw the bottom wall
        sta WSYNC
        lda #$FF
        sta PF0
        sta PF1
        sta PF2         ; straight line PF
        lda #0
        sta GRP0
        sta GRP1

.botloop
        sta WSYNC
        dex
        bne .botloop

        stx ENABL
        sta WSYNC

; 30 lines of overscan
        TIMER_SETUP 30

; check if BFlag is set
        lda BFlag
        bne skipbcheck
        lda Lasthit
        bmi player0b
        bit SWCHA
        bvc skipbcheck
        jmp done
player0b
        bit SWCHA
        bpl skipbcheck
        jmp done
skipbcheck
        lda #1
        sta BFlag

; check for ball collisions 
        bit CXP0FB              ; collision b/w player0 and ball
        bvs Player0Collision
        bit CXP1FB
        bvs Player1Collision
        bit CXBLPF              ; collision b/w PF and ball?
        bmi PlayfieldCollision
        bpl NoCollision

Player0Collision
        ; change ball velocity
        lda #0
        sta XBallVel

        ; check if it is top half or bottom half of player0
        ldx #2
        lda YPos0
        clc
        adc #PHeight/2
        sec
        sbc YBall
        sta Temp
        bmi StoreVel1
        ldx #$FE
        bne StoreVel1

Player1Collision
        ; change ball velocity
        lda #$FE
        sta XBallVel

        ; check if it is top half or bottom half of player0
        ldx #2
        lda YPos1
        clc
        adc #PHeight/2
        sec
        sbc YBall
        sta Temp
        bmi StoreVel1
        ldx #$FE
        bne StoreVel1

PlayfieldCollision
        ; if bouncing off top of playfield, bounce down
        ldx #2
        lda YBall
        bpl StoreVel2
; otherwise bounce up
        ldx #$FE
        jmp StoreVel2

StoreVel1
        lda Temp
        cmp #1
        bne StoreVel2
        ldx #0

StoreVel2
        ; store final velocity
        stx YBallVel
NoCollision
        ; clear collision registers for next frame
        sta CXCLR
        ; move ball vertically
        lda YBall
        clc
        adc YBallVel
        sta YBall

; move ball horizontally
        lda XBallVel
        bmi ballMoveLeft
        lda XBall
        cmp #157
        bcs resetball
        ldy #$F0
        lda Temp
        cmp #PHeight
        beq skipspeed1
        lda Temp
        cmp #$FE
        beq skipspeed1
        bne skip1
skipspeed1
        ldy #$E0
        inc XBall
skip1
        sty HMBL
        inc XBall
        bne applyMove
ballMoveLeft
        lda XBall
        cmp #15
        bcc resetball
        ldy #$10
        lda Temp
        cmp #PHeight
        beq skipspeed2
        lda Temp
        cmp #$FE
        beq skipspeed2
        bne skip2
skipspeed2
        ldy #$20
        dec XBall
skip2
        sty HMBL
        dec XBall
        bne applyMove

resetball
        sta Lasthit
        lda #0
        sta BFlag
        lda #BlStart
        sta YBall
        sta XBall
        ldx #4
        jsr SetHorizPos

applyMove
        sta WSYNC
        sta HMOVE
done

        lda Paddle0
        sta YPos0
        lda Paddle1
        sta YPos1
        TIMER_WAIT
; total = 262 lines, go to next frame
        jmp NextFrame

; SetHorizPos routine
; A = X coordinate
; X = player number (0 or 1)
        align 256
SetHorizPos
        sta WSYNC
        ;SLEEP 3
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

;-------------------------------------------------------------------------------
; Epilogue

        org $FFFC
        .word Start     ; reset vector
        .word Start     ; BRK vector


