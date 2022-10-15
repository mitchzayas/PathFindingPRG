; -------------------------------------------------------
; This subroutine initializes vars for wave propagation
; -------------------------------------------------------
;
.proc WaveInit
        lda #219                   ; NodeGoal value
        sta NodeGoal
        ldy #1                      ; NodeStart value
        sty NodeStart
;
        ldx #0                    ; max nodes possible = 239
        lda #0
        sta reCalcFlag
        sta FLAG_Quit               ; quit program flag is 0
        sta AlgoDone                ; 0 = Algo not done; 1 = done
        sta GridXMin
        sta GridYMin    
        sta NodeArrayElementCount
        sta NeighArrayElementCount      
        sta NodeArrayElementIndex
        sta NeighArrayElementIndex
        dec NodeArrayElementIndex   ; start at 255 (-1)
        dec NeighArrayElementIndex  ; start at 255 (-1)
            
@loop1:
        sta NodeScore,x             ; init all 3 arrays to 0
        sta NodeArray,x 
        sta NeighborArray,x 
        inx
        cpx #240
        bcc @loop1
;
        ldx NodeGoal                ; propagate from NodeGoal outwards
        stx NodeArray
        stx NodeCurrent
        inc NodeArrayElementIndex   ; this is a 0 now (first element)    
        inc NodeArrayElementCount   ; we have 1 element in NodeArray now (this is a 1 now)
        lda #1
        sta NodeScore,x             ; store a score of 1 for NodeGoal
;
        lda #11                     ; Init Grid Size: 12 nodes down
        sta GridYMax
        sta ZP1
        ldy #19                      ; 20 nodes across (0-19)
        sty GridXMax
        sty ZP2
        iny
        sty GridWidth                ; Width of grid is 20
;
        ldy #239                     ; 240 nodes in grid (0-239)
@loop2:
        ldx ZP2                      ; GridX
@loop3:        
        txa 
        sta NodeX,y                  ; set XPos of Node
        lda ZP1                      ; GridY
        sta NodeY,y                  ; set YPos of Node
        dey
        dex 
        bpl @loop3
        dec ZP1
        bpl @loop2
;
        lda #<moveGoal          ; change the default to "Move Goal SubRoutine"
        sta kbSubHandler+1      ; employs self-modifying code
        lda #>moveGoal
        sta kbSubHandler+2
;
        lda #109
        sta CursorOldPos        ; default cursor position in the middle of grid
        sta CursorPos
        rts
.endproc
; -------------------------------------------------------
; This subroutine finds neighbors & scores them
; -------------------------------------------------------
;
.proc FindScoreNeighbors
; ------------------------------------------------------------------
; Get LEFT NEIGHBOR
; ------------------------------------------------------------------
;
        ldx NodeArrayElementIndex
@loop1:
        lda NodeArray,x
        sta NodeCurrent
        tax                             ; x contains currentNode 
;
        ldy NodeCurrent                 
        lda NodeX,y 
        beq @FindRight                  ; no possible neighbor to the left, if column = 0
        
        dey                             ; point to left neighbor
        lda NodeScore,y
        bne @FindRight                  ; Not 0 = we skip Left Neighbor
;
        lda NodeScore,x                 ; x points to currentNode
        clc
        adc #1                          ; Neighbor's score is CurrentNode+1
        sta NodeScore,y                 ; y points to neighbor node
;
        inc NeighArrayElementIndex
        inc NeighArrayElementCount
        tya                             ; points to neighbor node
        ldy NeighArrayElementIndex
        sta NeighborArray,y
; ------------------------------------------------------------------
; Get RIGHT NEIGHBOR
; ------------------------------------------------------------------
;
@FindRight:
;
        ldy NodeCurrent                 
        lda NodeX,y
        cmp GridXMax                    ; if its 19, there can be no right neighbor
        bcs @FindTop                    ; no possible neighbor to the right
        
        iny                             ; point to left neighbor
        lda NodeScore,y
        bne @FindTop                    ; Not 0 = we skip Neighbor
;
        lda NodeScore,x                 ; x points to currentNode
        clc
        adc #1                          ; Neighbor's score is CurrentNode+1
        sta NodeScore,y                 ; y points to neighbor node
;

        inc NeighArrayElementIndex
        inc NeighArrayElementCount
        tya                             ; points to neighbor node
        ldy NeighArrayElementIndex
        sta NeighborArray,y
; ------------------------------------------------------------------
; Get TOP NEIGHBOR
; ------------------------------------------------------------------
;
@FindTop:
;       
        ldy NodeCurrent
        lda NodeY,y
        beq @FindBottom
;
        tya     
        sec
        sbc GridWidth
        tay
;
        lda NodeScore,y 
        bne @FindBottom
;
        lda NodeScore,x 
        clc
        adc #1
        sta NodeScore,y 
;
        inc NeighArrayElementIndex
        inc NeighArrayElementCount
        tya                             ; points to neighbor node
        ldy NeighArrayElementIndex
        sta NeighborArray,y
; ------------------------------------------------------------------
; Get BOTTOM NEIGHBOR
; ------------------------------------------------------------------
;
@FindBottom:
;       
        ldy NodeCurrent
        lda NodeY,y
        cmp GridYMax
        bcs @NeighDone
;
        tya     
        clc
        adc GridWidth
        tay
;
        lda NodeScore,y 
        bne @NeighDone
;
        lda NodeScore,x 
        clc
        adc #1
        sta NodeScore,y 
;
        inc NeighArrayElementIndex
        inc NeighArrayElementCount
        tya                             ; points to neighbor node
        ldy NeighArrayElementIndex
        sta NeighborArray,y
;
@NeighDone:
        dec NodeArrayElementIndex
        dec NodeArrayElementCount
        ldx NodeArrayElementIndex
        bmi @Done
        jmp @loop1
@Done:
        rts

.endproc

; -------------------------------------------------------
; This subroutine checks if NeighArray is blank (i.e. done!)
; if not blank, it moves elements to NodeArray
; -------------------------------------------------------
;
.proc IsWaveDone
        ldx NeighArrayElementCount
        bne @KeepGoing
        lda #1
        sta AlgoDone
        jmp @Done
;
@KeepGoing:
        stx NodeArrayElementCount
        ldx NeighArrayElementIndex      ; copy NeighArray indexes to NodeArray indexes
        stx NodeArrayElementIndex       ; x points to Neigh index
;
@Loop1:
        lda NeighborArray,x 
        sta NodeArray,x                 ; transer NeighArray --> NodeArray
        dec NeighArrayElementCount      ; 0 when done --> no elements
        dec NeighArrayElementIndex      ; $FF when done --> no elements
        dex
        bpl @Loop1
@Done:
        rts
.endproc
        



