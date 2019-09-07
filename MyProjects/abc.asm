; '2600 alphabetic letters A, B, C

        processor 6502
        include "vcs.h"
        include "macro.h"

;--------------------------------------------------------------------------------
; Variable space allocation

        SEG.U vars
        ORG $80         ; start of RAM

charPos ds 1            ; a 1-byte variable

;--------------------------------------------------------------------------------
; Constants assignments

TIME_TO_CHANGE = 100         ; speed of "animation" - change as desired

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

        lda #0
        sta charPos         ; set the first alpha-char position

        ldy #0              ; "speed" counter

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

;--------------------------------------------------------------------------------
; Handle a change in the pattern once every 20 frames

        iny                         ; increment speed count by one
        cpy #TIME_TO_CHANGE         ; has it reached our "change point"?
        bne notyet                  ; no, so branch past

        ldy #0                      ; reset speed count
        inc charPos                 ; increment character position

        lda charPos
        cmp #3                      ; check if charPos is at last letter
        bne notyet                  ; no, so branch past

        lda #0                      
        sta charPos                 ; reset charPos back to 0

notyet

;--------------------------------------------------------------------------------
; Do 192 scanlines of picture

; Draw a blank image before start of letter

        ldx #0          ; this counts our scanline number

TopBlank
        sta WSYNC       ; wait until end of scanline
        inx             ; 2 cycles
        cpx #76         ; 2 cycles
        bne TopBlank    ; 2 cycles

; Determine which letter to draw (first 13 chars cmp in scanline 75)
        lda charPos     ; 3 cycles
        cmp #0          ; 2 cycles
        bne passA
        jmp CharA       ; 3 cycles
passA
        cmp #1
        bne passB
        jmp CharB
passB
        cmp #2
        bne passC
        jmp CharC
passC

; Draw the 'A' letter
CharA;--------------------------------------------------------------------------

        lda #$01
        sta CTRLPF      ; set PF mirroring

        lda #$80        ; draw the top of the 'A'
        sta PF2
        ldx #0

A1
        sta WSYNC
        inx
        cpx #8
        bne A1

        lda #$40        ; draw the top edge of 'A'
        sta PF2
        ldx #0

A2
        sta WSYNC
        inx
        cpx #16
        bne A2

        lda #$C0        ; draw the middle of 'A'
        sta PF2
        ldx #0

A3
        sta WSYNC
        inx
        cpx #8
        bne A3

        lda #$40        ; draw the bottom of 'A'
        sta PF2
        ldx #0

A4
        sta WSYNC
        inx
        cpx #8
        bne A4

        jmp Done        ; 'A' char is drawn

; Draw the 'B' letter
CharB;----------------------------------------------------------------------------

        ldx #0          ; 2 cycles

B1
        lda #$C0        ; draw the top of 'B', 2 cycles
        sta PF2         ; 3 cycles

        SLEEP 5

        lda #$10
        sta PF0

        SLEEP 25
        lda #0
        sta PF2

        sta WSYNC
        lda #0
        sta PF0
        inx
        cpx #8
        bne B1


        lda #$01        ; turn PF mirroring on
        sta CTRLPF
        ldx #0

        lda #0
        sta PF0         ; reset PF0

        lda #$40        ; draw top mid section of 'B'
        sta PF2

B2
        sta WSYNC
        inx
        cpx #8
        bne B2


        lda #$C0        ; draw mid section of 'B'
        sta PF2
        ldx #0

B3
        sta WSYNC
        inx
        cpx #8
        bne B3


        lda #$40        ; draw bot mid section of 'B'
        sta PF2
        ldx #0

B4
        sta WSYNC
        inx
        cpx #8
        bne B4



        ldx #0          ; 2 cycles

B5
        lda #$C0        ; draw the bot of 'B', 2 cycles
        sta PF2         ; 3 cycles

        lda #0          ; 2 cycles
        sta CTRLPF      ; turn off mirroring, 3 cycles

        lda #$10
        sta PF0

        SLEEP 25
        lda #0
        sta PF2

        sta WSYNC
        lda #0
        sta PF0
        inx
        cpx #8
        bne B5

        jmp Done        ; 'B' char is drawn

; Draw the 'C' letter
CharC;--------------------------------------------------------------------------
        lda #$01        
        sta CTRLPF      ; turn on PF mirroring
        lda #$C0        
        sta PF2         ; draw the top of 'C', 3 cycles 
        ldx #0

C1
        sta WSYNC
        inx             ; 2 cycles
        cpx #8          ; 2 cycles
        bne C1          ; 2 cycles

        lda #$40
        sta PF2         ; draw the top mid of 'C'
        ldx #0          ; 2 cycles

C2
        sta WSYNC
        inx             ; 2 cycles
        cpx #8          ; 2 cycles
        bne C2          ; 2 cycles

        ldx #0          ; 2 cycles
        stx CTRLPF      ; turn PF mirroring off

C3
        lda #$40
        sta PF2         ; draw the mid of 'C'

        SLEEP 45        ; wait for PF2 to finish displaying
        lda #0
        sta PF2         ; turn off PF2

        sta WSYNC
        inx
        cpx #8
        bne C3

        lda #$40
        sta PF2         ; draw the bot mid of 'C'
        lda #$01
        sta CTRLPF      ; turn PF mirroring on
        ldx #0

C4
        sta WSYNC
        inx
        cpx #8
        bne C4

        lda #$C0
        sta PF2         ; draw bot of 'C'
        ldx #0

C5
        sta WSYNC
        inx
        cpx #8
        bne C5

        jmp Done 

; Draw a blank image at bottom of characters
Done

        lda #0          
        sta PF2         ; reset PF2
        sta PF0         ; reset PF0
        sta CTRLPF      ; reset CTRLPF
        ldx #0

BotBlank
        sta WSYNC
        inx
        cpx #76
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

