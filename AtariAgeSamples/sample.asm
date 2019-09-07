                processor 6502
                include "vcs.h"
                include "macro.h"
 
                SEG.U   VARS
                ORG $80

Paddle0     byte
                
 
                SEG
                ORG $F000 
             
CompleteReset
                CLEAN_START


            lda #$FF
            sta COLUP0
            lda #$55
            sta COLUBK
            lda #70
            sta Paddle0



StartOfFrame  

; DGS - need to black out the screen
; else the TV will have problems detecting the VSYNC signal     
    lda #$82
    sta WSYNC ; wait for end of scanline
    sta VSYNC ; as VSYNC must be at start of scanline
    sta VBLANK ; start vertical blank AND dump paddles to ground


; DGS            ;lda #$82 ;-- this causes a black screen
; DGS            lda #$80 ;- this lets me see the screen
; DGS            sta VBLANK
; DGS            lda #2 ;-- this is needed because I use #$80 above ($82 doesn't work)
; DGS            sta VSYNC
            sta WSYNC; 3 scanlines of VSYNC signal
            sta WSYNC
            sta WSYNC 
            lda #0
            sta VSYNC

            ldy #0
VerticalBlank   

; DGS this is IMMEDIATE MODE, means LDA #$80, you need to use LDA Zero_Page
;         lda #Paddle0 ; get the X coodinate from Paddle0 and store it in A
        lda Paddle0
         ldx #0  ; set X to sprite number (0 or 1)
         jsr SetXPosition 
         sta WSYNC;37
         sta HMOVE	; gotta apply HMOVE
        
.loop
               sta WSYNC
                iny
                cpy #37
                bne .loop
           
    ; DGS at turn screen on at end of Vertical Blank
    sta WSYNC
    sty VBLANK ; Y is 0 due to the .loop above

            ldx #192
            ldy #8;number of lines in sprite
            
    ; DGS need to set Paddle0 to the highest value
    stx Paddle0
Picture

    ; X contains the scan line
    ;dump the paddle register into A
            lda INPT0      ; paddle discharged?
            
; DGS need to use bpl, not bmi            
;            bmi .dopaddle   ; N flag is set - store value 
            bpl .dopaddle   ; N flag is clear - store value 
            .byte $2c     ; skip next instruction (BIT opcode) 
.dopaddle stx Paddle0     ;store the scanline # into Paddle0

             
            CPX #13 ;draw sprite this many lines up from the bottom
            BEQ .showsprite
            CPY #8;number of lines in sprite
            BEQ .end
            LDA Sprite0,Y;test player0
             BEQ .end;if we find zeros in it, 
                    ;then we are at the end of this sprite frame

.showsprite
            dey
            lda Sprite0,Y; look up sprite data 
            sta GRP0; set player 0 bitmap register 
            

.end
            dex
            CLC;this is important for the compares above to work
            sta WSYNC 
            bne Picture







                lda #%01000010
                sta VBLANK          ;enter blanking for overscan.
                ldx #0
Overscan        
                sta WSYNC
                inx
                cpx #30
                bne Overscan



                JMP StartOfFrame



SetXPosition
	sta WSYNC	; start a new line
	sec		; set carry flag
DivideLoop
	sbc #15		; subtract 15
	bcs DivideLoop	; branch until negative
	eor #7		; calculate fine offset
	asl
	asl
	asl
	asl
	sta HMP0,x	; set fine offset
	sta RESP0,x	; fix coarse position
	rts		; return to caller





Sprite0 
        .byte #%00000000
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
				

            ORG $FFFA 



InterruptVectors



            .word CompleteReset          ; NMI
            .word CompleteReset          ; RESET
            .word CompleteReset          ; IRQ



      END

