        processor 6502
        include "vcs.h"
        include "macro.h"

;-------------------------------------------------------------------------------
; Define/assign constant variables

PHeight     = 8
BlHeight    = 2
P0XPos      = 10
P1XPos      = 158

;-------------------------------------------------------------------------------
; Define RAM variables

        seg.u Variables
        org $80

YBall       ds 1
YBallVel    ds 1
XBallVel    ds 1
XBallErr    ds 1
YPos0       ds 1
YPos1       ds 1
Paddle0     ds 1
Paddle1     ds 1
P0Temp      ds 1
P1Temp      ds 1

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

        lda #80
        sta YPos0
        sta YPos1
        sta YBall
        lda #$45
        sta COLUP0
        sta COLUP1
        lda #$08
        sta COLUPF

        ; set player horizontal positions
        lda #P0XPos      ; get X coordinate
        ldx #0          ; player 0
        jsr SetHorizPos ; set coarse offset
        lda #P1XPos
        ldx #1
        jsr SetHorizPos

        ; set ball horizontal position
        lda #84
        ldx #4
        jsr SetHorizPos
        sta WSYNC       ; sync w/ scanline
        sta HMOVE       ; apply fine offsets

        ; set ball initial velocity
        lda #1
        sta YBallVel
        lda #$30
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
        TIMER_WAIT

        lda #0
        sta VBLANK      ; turn on display

        ; Draw the top wall
        lda #$FF
        sta PF0
        sta PF1
        sta PF2         ; straight line PF

        lda #0
.toploop
        sta WSYNC
        ;dey
        ;bne .toploop

        ; turn off PF
        lda #0
        sta PF0
        sta PF1
        sta PF2
        sta WSYNC

        ldx #92        ; X = 191 scanlines
        stx Paddle0
        stx Paddle1

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

        DRAW_BALL
        ldy #0
        READ_PADDLES
        ldy #1
        READ_PADDLES
        sta WSYNC

        DRAW_BALL
        dex
        bne LVScan

; 29 lines of overscan
        TIMER_SETUP 30
        ; move ball vertically
        lda YBall
        clc
        adc YBallVel
        sta YBall

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


