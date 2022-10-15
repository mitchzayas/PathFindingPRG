; -------------------------------------------------------
; This is the main game loop 
; -------------------------------------------------------
;
.include "src/PathFindingPRG/inits.asm"
.include "src/PathFindingPRG/tilesGraphics.asm"
.include "src/PathFindingPRG/waveP.asm"
.include "src/PathFindingPRG/optimalPath.asm"
.include "src/PathFindingPRG/io.asm"
.include "src/PathFindingPRG/resetValues.asm"
;
.CODE
.proc gameLoop
;
; Init HGR & Wave Vars
; -------------------------------------------------------
;
        jsr HGRFULL
        ldy #$00                ; HGR1 Address
        ldx #$20
        lda #0                  ; black
        jsr CLEARSCR
;
        jsr WaveInit
; -- draw each tile in the scores array
        jsr drawEmptyGrid
;
; Based on Start, End Node, Walkable Nodes -- cast a wave
; -------------------------------------------------------
;
@Loop1:
        jsr FindScoreNeighbors
        jsr IsWaveDone
        lda AlgoDone
        beq @Loop1
        
        jsr FindPath
        jsr drawPath
@getKey:
        jsr keyin
        cpy #0
        beq @getKey
;
        jsr kbHandler           ; check if an action key was pressed (G,S,C,Q)
        jsr kbSubHandler        ; check if an arrow key (or O key) was pressed
        lda FLAG_Quit
        bne @donE
        lda reCalcFlag
        beq @getKey
;
        jsr resetValues
@Loop2:
        jsr FindScoreNeighbors
        jsr IsWaveDone
        lda AlgoDone
        beq @Loop2
        jsr FindPath
        jsr drawPath
        jmp @getKey

@donE:
        rts
.endproc

