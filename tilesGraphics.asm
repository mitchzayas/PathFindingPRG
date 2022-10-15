.proc HGRFULL
         LDA   $C050
         LDA   $C057
         LDA   $C054
         LDA   $C052
         RTS
.endproc
;********************************
.proc HGRMIX
         LDA   $C050
         LDA   $C057
         LDA   $C054
         LDA   $C053
         RTS
.endproc
;********************************
.proc HGR2
         LDA   $C050
         LDA   $C057
         LDA   $C055
         RTS
.endproc
;********************************
;Enter with Screen lo byte in YREG and hi byte in XREG AND COLOR IN ACC
.proc CLEARSCR
        STY GRLO
        STX GRHI
        ASL             ;MULTIPLY ACC BY 2 TO POINT TO CORRECT COLORS IN TABLE
        TAX             ;COLOR INDEX NOW IN XREG
        LDA HGRCOLS,x   ;GO GET EVEN COLUMN COLOR VALUE
        STA @PATCH1+1
        INX
        LDA HGRCOLS,x
        STA @PATCH2+1
        LDX GRHI

        CPX #$20        ;are we working on HGR Page1 ($2000-$4000)?
        BNE @PatchPage2 ;if no, we're working with HGR Page2
        LDA #$40        ;we're clearing page 1, which ends at $4000
@EndOfHGR:
        STA @PATCH3+1

@PATCH1:                ;PUT COLOR IN EVEN COLUMN
        LDA #0          ;#0 IS A DUMMY VALUE REPLACED BY SELF MODIFYING CODE            
        STA (GRLO),Y
        INY
@PATCH2:                ;PUT COLOR IN ODD COLUMN
        LDA #0          ;#0 IS A DUMMY VALUE REPLACED BY SELF MODIFYING CODE
        STA (GRLO),Y
        INY
        BNE @PATCH1
        INX 
        STX GRHI
@PATCH3:        
        CPX #0          ;#0 IS A DUMMY VALUE REPLACED BY SELF MODIFYING CODE
        BNE @PATCH1
        RTS             ;END. Return from Procedure

@PatchPage2:
        LDA #$60        ;we're clearing page 2, which ends at $6000
        JMP @EndOfHGR
.endproc

; -------------------------------------------------------
; enter with the HRGrid Index in the XREG (0-239)
; enter with tile number to draw in ACC
; -------------------------------------------------------
;
.proc drawTile
        sta tileIndex   ;up to 128 tiles can be pointed to
        asl             ;index into 2-byte pointer table TILES
        tay
        lda TILES,Y
        sta tile_ptr
        iny
        lda TILES,Y
        sta tile_ptr+1

        lda HR1GRID_HI,X
        sta @dr0+2
        sta @dr8+2
        clc
        adc #4
        sta @dr1+2
        sta @dr9+2
        clc
        adc #4
        sta @dr2+2
        sta @dr10+2
        clc
        adc #4
        sta @dr3+2
        sta @dr11+2
        clc
        adc #4
        sta @dr4+2
        sta @dr12+2
        clc
        adc #4
        sta @dr5+2
        sta @dr13+2
        clc
        adc #4
        sta @dr6+2
        sta @dr14+2
        clc
        adc #4
        sta @dr7+2
        sta @dr15+2

        lda HR1GRID_LO,X
        sta @dr0+1
        sta @dr1+1
        sta @dr2+1
        sta @dr3+1
        sta @dr4+1
        sta @dr5+1
        sta @dr6+1
        sta @dr7+1
        
        clc
        adc #$80
        sta @dr8+1
        sta @dr9+1
        sta @dr10+1
        sta @dr11+1
        sta @dr12+1
        sta @dr13+1
        sta @dr14+1
        sta @dr15+1

        ldy #0                  ;index into tiles pointed to by tile_ptr starting with 0-15 then 16-31
        ldx #0                  ;we have to do 2 columns (bytes) of tiles (0-7 and 8-14)

@nextByte:
        lda (tile_ptr),Y
@dr0:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr1:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr2:   sta dummy,x
        iny
        lda (tile_ptr),Y
@dr3:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr4:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr5:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr6:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr7:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr8:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr9:   sta dummy,X
        iny
        lda (tile_ptr),Y
@dr10:  sta dummy,X
        iny
        lda (tile_ptr),Y
@dr11:  sta dummy,X
        iny
        lda (tile_ptr),Y
@dr12:  sta dummy,X
        iny
        lda (tile_ptr),Y
@dr13:  sta dummy,X
        iny
        lda (tile_ptr),Y
@dr14:  sta dummy,X
        iny
        lda (tile_ptr),Y
@dr15:  sta dummy,X

        iny
        inx
        cpx #2
        bcc @nextByte

        rts
.endproc
;
; -------------------------------------------------------
; Draws grid based on NodeScore values.
; If NodeScore = $FF, it skips that node, else
; it just draws an empty tile
; -------------------------------------------------------
;
.proc drawEmptyGrid   
        ldx #0            ; start with the last node
        stx ZP1
@Loop1:
        lda NodeScore,x
        cmp #$FF
        beq @Obstacle
@DrawIt:
        jsr drawTile
        ldx ZP1
        inx
        stx ZP1
        cpx #240
        bcc @Loop1
        rts
@Obstacle:
        lda #4             ; this is the tile for an obstable
        jmp @DrawIt
.endproc

.proc drawPath
        ldx PathIndex
        stx ZP14
@Loop1:
        lda Path,x 
        tax
        lda #3
        jsr drawTile
        dec ZP14
        ldx ZP14
        bpl @Loop1
;
        ldx NodeStart
        lda NodeScore,x 
        jsr eraseTile
        ldx NodeStart
        lda #2             ; Start Tile is tile #3
        jsr drawTile
;
        ldx NodeGoal
        lda NodeScore,x 
        jsr eraseTile
        ldx NodeGoal
        lda #1              ;Goal Tile is #2
        jsr drawTile
        rts
.endproc

.proc erasePath
        ldx PathIndex
        stx ZP1
@Loop1:
        lda Path,x 
        tax
        lda NodeScore,x
        jsr eraseTile
        dec ZP1
        ldx ZP1
        bpl @Loop1
        rts
.endproc

; -------------------------------------------------------
; enter with the HRGrid Index in the XREG (0-239)
; enter with tile number to draw in ACC
; -------------------------------------------------------
;
.proc eraseTile
        cmp #$FF
        beq @Obstacle
        lda #0
@DrawIt:
        jsr drawTile
        rts
@Obstacle:
        lda #4
        jmp @DrawIt 
.endproc 

