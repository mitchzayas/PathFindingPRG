; -------------------------------------------------------
; This subroutine resets arraays and key vars when a
; key was pressed, in preparation for casting a new wave
; and finding a new path
;
; enter with: -
; exit with: -
; -------------------------------------------------------
;
.proc resetValues

        jsr zeroScores
        lda #0
        sta AlgoDone
        sta reCalcFlag
        sta NodeArrayElementCount
        sta NeighArrayElementCount      
        sta NodeArrayElementIndex
        sta NeighArrayElementIndex
        dec NodeArrayElementIndex   ; start at 255 (-1)
        dec NeighArrayElementIndex  ; start at 255 (-1)

        ldx NodeGoal                ; propagate from NodeGoal outwards
        stx NodeArray
        stx NodeCurrent
        inc NodeArrayElementIndex   ; this is a 0 now (first element)    
        inc NodeArrayElementCount   ; we have 1 element in NodeArray now (this is a 1 now)
        lda #1
        sta NodeScore,x             ; store a score of 1 for NodeGoal
        rts
.endproc

.proc zeroScores
        ldx #0
        ldy #0
@Loop1:
        lda NodeScore,x 
        bmi @skip
        tya 
        sta NodeScore,x 
@skip:
        inx
        cpx #240
        bcc @Loop1
        rts
.endproc