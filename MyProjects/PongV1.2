
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Pong V1.1 by Anthony R. Garcia (09/04/2019)
; --Based on Video Olympics (1977) by Atari/Sears
;
; Credit Sources:
;   -Andrew Davie's Atari 2600 Programming for Newbies
;   -Steven Hugg's Making Games for the Atari 2600
;   -Steve Wright's Stella Programmer's Guide
;   -The amazing community at AtariAge forums
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        processor 6502
        include "vcs.h"
        include "macro.h"

;-------------------------------------------------------------------------------
; Define/assign constant variables

PHeight     equ 16      ; height of player sprites
PWidth      equ $F0     ; width of player sprites
P0XPos      equ 15      ; X (horizontal) position of P0
P1XPos      equ 142     ; X (horizontal) position of P1
BlHeight    equ 4       ; height of ball
BlStart     equ 80      ; starting position of ball (X & Y)

;-------------------------------------------------------------------------------
; Define RAM variables

        seg.u Variables
        org $80

YBall       byte        ; ball's Y coord
XBall       byte        ; ball's X coord
YBallVel    byte        ; ball's Y velocity
XBallVel    byte        ; ball's X velocity
BlFlag      byte        ; flag to turn ball display on/off

P0YPos      byte        ; P0's Y coord
P1YPos      byte        ; P1's Y coord

Paddle0     byte        ; store paddle0 controller input
Paddle1     byte        ; store paddle1 controller input

Score0      byte        ; BCD score for P0
Score1      byte        ; BCD score for P1
ScoreBuf    ds 10       ; 2x5 array of PF bytes (for score keeping)
MaskFlag0   byte        ; boolean for masking leading zeros for 0-9 Score0
MaskFlag1   byte        ; boolean for masking leading zeros for 0-9 Score1

LastHit     byte        ; neg ($FF) if P0 scored, pos otherwise: use N PS flag
Temp        byte        ; placeholder var for ball physics
Temp2       byte        ; placeholder var for score
avol0       byte        ; shadow register for AVOL0
XBallTemp   byte

;-------------------------------------------------------------------------------
; Set-up macros

        ; Polls paddle capacitor and stores scanline number if discharged
        ; Argument(s): X reg = scanline number
        ; 20 cycles (WC)
        MAC READ_PADDLES
        lda INPT0           ; load paddle0 register | +3
        bpl .save0          ; discharged?, then store value | +2/3, +1 PB
        .byte $2c           ; skip next instruction | +4
.save0
        stx Paddle0         ; +3
        lda INPT1           ; load paddle1 register | +3
        bpl .save1          ; discharged?, then store value | +2/3, +1 PB
        .byte $2c           ; skip next instruction | +4
.save1
        stx Paddle1         ; +3
        ENDM

        ; Determine whether to draw ball on current scanline
        ; Argument(s): X reg = scanline number
        ; 19 cycles (WC)
        MAC DRAW_BALL
        txa                 ; +2
        sec                 ; +2
        sbc YBall           ; +3
        cmp #BlHeight       ; used for > 1 scanline ball | +2
        lda #0              ; +2
        bcs .noball         ; +2/3, +1 PB
        lda #$02            ; turn ball on | +2
.noball
        sta ENABL           ; +3
        ENDM

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
; Code segment [Start of ROM]

        seg Code
        org $F000

Start
        CLEAN_START         ; clear memory and regs to 0, set SP to $FF

        ; set colors
        lda #$F0
        sta COLUBK          ; set BK color
        lda #$38
        sta COLUP0          ; set P0 color
        lda #$2C;#$D6
        sta COLUP1          ; set P1 color
        lda #$0E
        sta COLUPF          ; set PF color

        ; set players/ball vertical position
        lda #80             
        sta P0YPos          
        sta P1YPos
        sta YBall

        ; set ball horizontal position
        lda #BlStart        
        sta XBall
        ldx #4              ; ball memory address offset
        jsr SetHorizPos

        ; set ball initial velocity
        lda #$FF            ; go left (negative x direction)
        sta YBallVel
        sta XBallVel

        ; set ball thickness
        lda #$10            ; 2x clock thickness
        sta CTRLPF

        ; misc initializations
        lda #1
        sta BlFlag          ; draw ball
        lda #$01
        sta VDELP0          ; delay GRP0 write until GRP1 write

NextFrame
        ; handle console switches
        lsr SWCHB           ; test Game Reset switch
        bcc Start           ; reset?

;-------------------------------------------------------------------------------
; VSync & Vertical Blank section (40 scanlines)

        VERTICAL_SYNC       ; 3 scanlines (start of new frame)

        lda #$82
        sta VBLANK          ; turn off video, dump paddles to ground

        TIMER_SETUP 37      ; start timer for VBlank

        ; turn off PF graphics from last frame
        lda #0
        sta PF0
        sta PF1
        sta PF2

        ; update scoreboard
        lda Score0
        ldx #0
        cmp #10
        bcs skipmask0       ; check if score < 10
        ldx #1              ; set flag to mask leading zero
skipmask0
        stx MaskFlag0
        ldx #0
        jsr GetBCDBitmap    ; sets ScoreBuf+0 - ScoreBuf+4

        lda Score1          ; do same for Score1 as above
        ldx #0
        cmp #10
        bcs skipmask1
        ldx #1
skipmask1
        stx MaskFlag1
        ldx #5
        jsr GetBCDBitmap    ; sets ScoreBuf+5 - ScoreBuf+9

        TIMER_WAIT          ; end timer for VBlank

;-------------------------------------------------------------------------------
; Display section (192 scanlines)

        lda #0
        sta VBLANK          ; turn display back on

; Draw the scoreboard (192 - 21 = 171 scanlines)
		lda #$12
		sta CTRLPF          ; score mode (leftPF = P0color, rightPF = P1color)

        sta WSYNC
        sta WSYNC           ; 2 scanline gap from top of screen

        ; draw all four digits
        ldy #0              ; Y will contain the frame Y-coord
ScanLoop1
        sta WSYNC
        tya
        lsr                 ; divide Y by four for quad-height lines
        lsr
        tax
        stx Temp2
        lda ScoreBuf+0,x
        ldx MaskFlag0       ; check if Score0 is 0-9
        cpx #0
        beq nomask0
        and #$0F            ; mask left score bitmap
nomask0
        sta PF1             ; set left score bitmap
        ldx Temp2
        lda ScoreBuf+5,x
        ldx MaskFlag1       ; check if Score1 is 0-9
        cpx #0
        beq nomask1
        and #$0F            ; mask left score bitmap
nomask1
        SLEEP 4
        sta PF1             ; set right score bitmap
        iny
        cpy #20             ; 20 scanlines
        bcc ScanLoop1

        ; set-up memory for next section
        lda #0
        sta WSYNC
        sta PF1
        lda #$10
        sta CTRLPF          ; disable score mode, keep ball thickness

; Draw the top wall (171 - 11 = 160 scanlines)
        lda #$FF
        sta WSYNC           ; 2 scanline gap between score/PF
        sta PF0
        sta PF1
        sta PF2             ; draw a straight bar across screen

        ldx #168            ; X = number of display scanlines remaining
        ; set-up paddle values w/ remaining display scanline number
        stx Paddle0
        stx Paddle1
topwall
        sta WSYNC
        lda BlFlag          ; check if ball should be drawn
        beq skipbl1
        DRAW_BALL           ; for collision purposes
skipbl1
        dex
        cpx #162            ; draw the bar 8 scanlines high
        bne topwall

        ; set-up memory for next section
        lda #0
        sta WSYNC
        dex
        sta PF0
        sta PF1
        sta PF2             ; turn off PF graphics
        lda #$12
        sta CTRLPF          ; turn on score mode, keep ball thickness
        sta WSYNC
        dex

; Draw players/ball: 2 line kernel
MainKernel
        ; check if P0 should be drawn
        txa
        sec
        sbc P0YPos
        ldy #PWidth
        cmp #PHeight        ; in P0 sprite?
        bcc Player1         
        ldy #0              ; turn off P0
Player1
        sty GRP0            ; set-up P0 graphics until GRP1 write
        ; check if P1 should be drawn
        txa
        sec
        sbc P1YPos
        ldy #PWidth
        cmp #PHeight        ; in P1 sprite?
        bcc InSprite
        ldy #0
InSprite
        sta WSYNC
        sty GRP1            ; turn on both P0 and P1

        ; first check if ball should be drawn
        lda BlFlag
        beq skipbl2
        DRAW_BALL
skipbl2
        ; poll paddle capacitors
        READ_PADDLES        ; read paddles
        dex
        sta WSYNC

        ; second check if ball should be drawn
        lda BlFlag
        beq skipbl3
        DRAW_BALL
skipbl3
        dex
        cpx #6              ; leave 6 scanlines left in display
        bne MainKernel

        lda #$10
        sta CTRLPF          ; turn off score mode, keep ball thickness

; Draw the bottom wall
        sta WSYNC
        dex
        lda #$FF
        sta PF0
        sta PF1
        sta PF2             ; straight line PF
        lda #0
        sta GRP0
        sta GRP1            
botloop
        sta WSYNC
        dex
        bne botloop
        stx ENABL           ; turn off ball graphics

;-------------------------------------------------------------------------------
; Overscan section (30 scanlines)

        TIMER_SETUP 29      ; 30 - 1, since TIMER_WAIT adds a 'sta WSYNC'

; check if BlFlag is set
        lda BlFlag
        bne skipblcheck     ; if flag == 1 (draw), skip
        lda LastHit
        bmi player0b        ; if N==1, player0 was the last to score
        bit SWCHA
        bvc skipblcheck     ; check if P1 pressed button
        jmp Done            ; if not, skip checks and start new frame
player0b
        bit SWCHA
        bpl skipblcheck     ; check if P0 pressed button
        jmp Done            ; if not, skip checks and start new frame
skipblcheck
        lda #1
        sta BlFlag          ; start drawing the ball again

; check for ball collisions
        bit CXP0FB          ; collision b/w P0 and ball?
        bvs Player0Collision
        bit CXP1FB          ; collision b/w P1 and ball?
        bvs Player1Collision
        bit CXBLPF          ; collision b/w PF and ball?
        bmi PlayfieldCollision
        bpl NoCollision     ; no collisions happened

Player0Collision
        lda #0
        sta XBallVel        ; reverse ball velocity (go right)

        ; check if ball hit top half or bottom half of P0
        ldx #2              ; -2x speed, y-coord
        lda P0YPos
        clc
        adc #PHeight/2
        sec
        sbc YBall
        sta Temp            ; store to check if hit middle later
        bmi StoreYVel1      ; handle bottom half of P0
        ldx #$FE            ; +2x speed, y-coord
        bne StoreYVel1      ; handle top half of P0

Player1Collision
        lda #$FE
        sta XBallVel        ; reverse ball velocity (go left)

        ; check if ball hit top half or bottom half of P1
        ldx #2              ; -2x speed, y-coord
        lda P1YPos
        clc
        adc #PHeight/2
        sec
        sbc YBall
        sta Temp            ; store to check if hit middle later
        bmi StoreYVel1      ; handle bottom half of P1
        ldx #$FE            ; +2x speed, y-coord
        bne StoreYVel1      ; handle top half of P1

PlayfieldCollision
        ; if bouncing off top PF wall, bounce down
        ldx #2              ; -2x speed, y-coord
        lda YBall
        bpl StoreYVel2      ; bounce down? otherwise bounce up
        ldx #$FE            ; +2x speed, y-coord
        jmp StoreYVel2

StoreYVel1
        lda Temp
        cmp #0              ; check to see if middle was hit
        bne StoreYVel2      ; if not no change, otherwise set YVel = 0
        ldx #0
StoreYVel2
        stx YBallVel        ; store final velocity

; Make sound
        txa
        adc #45
        sta AUDF0           ; frequency
        lda #6
        sta avol0           ; shadow register for volume

NoCollision
        sta CXCLR           ; clear collision registers for next frame
        lda YBall
        clc
        adc YBallVel
        sta YBall           ; move ball vertically

; Move ball horizontally
        lda XBallVel
        bmi BallMoveLeft    ; check if ball is going left, other go right
        lda XBall
        cmp #157            ; scorezone past P1
        bcs ResetBall       ; if past, reset ball
        lda XBallTemp
        cmp #2
        beq DoubleVelR
        ldy #$F0            ; +1x speed, x-coord
        lda Temp
        cmp #$0C            ; check if ball hit top tip of paddle
        beq DoubleVelR 
        lda Temp
        cmp #$FE            ; check if ball hit bottom tip of paddle
        beq DoubleVelR
        bne SkipVelR
DoubleVelR
        ldy #$E0            ; +2x speed, x-coord
        inc XBall           ; compensate for 2x speed
        ldx #2
        stx XBallTemp
SkipVelR
        ;sty XBallTemp
        sty HMBL            ; set fine position for XBall
        inc XBall           ; track XBall position
        bne ApplyMove
BallMoveLeft
        lda XBall
        cmp #5              ; scorezone past P0
        bcc ResetBall       ; if past, reset ball
        lda XBallTemp
        cmp #2
        beq DoubleVelL
        ldy #$10            ; -1x speed, x-coord
        lda Temp
        cmp #$0C            ; check if ball hit top tip of paddle
        beq DoubleVelL
        lda Temp
        cmp #$FE            ; check if ball hit bottom tip of paddle
        beq DoubleVelL
        bne SkipVelL
DoubleVelL
        ldy #$20            ; -2x speed, x-coord
        dec XBall           ; compensate for 2x speed
        ldx #2
        stx XBallTemp
SkipVelL
        ;sty XBallTemp
        sty HMBL            ; set fine position for XBall
        dec XBall           ; track XBall position
        bne ApplyMove

ResetBall
        sta LastHit         ; holds either pos/neg value from b/f call
        lda #0
        sta BlFlag          ; turn ball drawing off
        sta Temp            ; reset horizontal speed
        sta XBallTemp       ; reset Ball velocity

        lda LastHit
        bmi P0lasthit       ; determine who last scored
        sed
        clc
        lda Score1
        adc #$01            
        sta Score1          ; Score1 += Score1
        jmp finishreset
P0lasthit
        sed
        clc
        lda Score0
        adc #$01
        sta Score0          ; Score0 += Score0
finishreset
        cld
        lda #BlStart
        sta YBall
        sta XBall
        ldx #4              ; offset for ball memory address
        jsr SetHorizPos

ApplyMove
        ; set player horizontal positions
        lda #P0XPos
        ldx #0              ; P0 memory address offset
        jsr SetHorizPos     ; set P0 Xpos
        lda #P1XPos
        ldx #1              ; P1 memory address offset
        jsr SetHorizPos     ; set P1 Xpos
        sta WSYNC
        sta HMOVE

Done
        lda Paddle0
        sta P0YPos          ; store P0 paddle value into y-coord
        lda Paddle1
        sta P1YPos          ; store P1 paddle value into y-coord

        ; play audio from shadow register
        ldx avol0
        beq NoAudio
        dex                 ; decrement volume every frame
        stx AUDV0           ; store in volume hardware register
        stx avol0           ; store in shadow register
        lda #3
        sta AUDC0           ; shift counter mode 3 for bounce sound
NoAudio

        TIMER_WAIT
        jmp NextFrame

;-------------------------------------------------------------------------------
; [Subroutine] SetHorizPos
; Algorithm that works out fine horizontal positioning of sprites
; Argument(s): A = X-coord, X = player number (0 or 1)

        align 256           ; avoid extra page-boundary crossing cycles
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

;-------------------------------------------------------------------------------
; [Subroutine] GetBCDBitmap
; Fetches bitmap data for two digits of a BCD-encoded number
; Argument(s): A = BCD number
; Returns: stores bitmap in addresses ScoreBuf+x to ScoreBuf+4+x

GetBCDBitmap
        ; First fetch the bytes for the 1st digit
        pha                 ; save original BCD number
        and #$0F            ; mask out the most significant digit
        sta Temp2
        asl
        asl
        adc Temp2            ; multiply by 5
        tay
        lda #5
        sta Temp2            ; count down from 5
.loop1
        lda DigitsBitmap,y
        and #$0F            ; mask out leftmost digit
        sta ScoreBuf,x      ; store rightmost digit
        iny
        inx
        dec Temp2
        bne .loop1
        
        ; Now do the 2nd digit
        pla                 ; restore original BCD number
        lsr
        lsr
        lsr
        lsr                 ; shift right by 4 (in BCD, divide by 10)
        sta Temp2
        asl
        asl
        adc Temp2            ; multiply by 5
        tay
        dex
        dex
        dex
        dex
        dex                 ; subtract 5 from X (reset to original)
        lda #5
        sta Temp2            ; count down from 5
.loop2
        lda DigitsBitmap,y
        and #$F0            ; mask out rightmost digit
        ora ScoreBuf,x      ; combine left and right digits
        sta ScoreBuf,x      ; store combined digits
        iny
        inx
        dec Temp2
        bne .loop2
        rts

;-------------------------------------------------------------------------------
; Bitmap pattern for digits

        .align 256          ; avoid added page-boundary crossing cycles
DigitsBitmap
		.byte $EE,$AA,$AA,$AA,$EE
        .byte $22,$22,$22,$22,$22
        .byte $EE,$22,$EE,$88,$EE
        .byte $EE,$22,$66,$22,$EE
        .byte $AA,$AA,$EE,$22,$22
        .byte $EE,$88,$EE,$22,$EE
        .byte $EE,$88,$EE,$AA,$EE
        .byte $EE,$22,$22,$22,$22
        .byte $EE,$AA,$EE,$AA,$EE
        .byte $EE,$AA,$EE,$22,$EE

;-------------------------------------------------------------------------------
; Epilogue

        org $FFFC
        .word Start         ; reset vector
        .word Start         ; BRK vector

