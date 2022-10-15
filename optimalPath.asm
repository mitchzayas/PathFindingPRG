; -------------------------------------------------------
; This subroutine finds optimal path using Wave Propagation
; call this after Wave Scores Array is already done
; -------------------------------------------------------
;
.proc FindPath        
;
        lda #$FF        
        sta PathIndex           ; No elements in Path Array (set to -1)
        lda #127
        sta ZP1                 ; ZP1 contains a high score initially (127)
        ldx NodeStart           ; Path starts where the player is (NodeStart)
        stx NodeCurrent
;
        inc PathIndex           ; We're adding NodeStart to Path Array, so PathIndex = 0
        txa                     ; NodeCurrent is now in ACC
        ldy PathIndex
        sta Path,y              ; NodeStart now first element of Path Array
;
@Loop1:
        lda #$FF
        sta LowestScoreNode     ; Do this each loop to see if path not possible ($FF remains)
        cpx NodeGoal            ; Is NodeCurrent = NodeGoal? If so, we found the path
        bne @CheckLeft
        lda #1                  ; 1 = Path found. 2 = no path possible (checked below)
        jmp @DoneOut            
; ------------------------------------------------------------------
; Check LEFT NEIGHBOR
; ------------------------------------------------------------------
;
@CheckLeft:
        lda NodeX,x             ; if NodeCurrent's X Value is 0, left neighbor not possible
        beq @CheckRight         ; saving a CMP to GridXMIN, since its 0 anyway
;
        dex                     ; point to left neighbor
        lda NodeScore,x         ; if it's score is negative, then its not walkable
        bmi @CheckRight         ; so skip left neighbor check
        cmp ZP1                 ; if it's score is > = ZP1 (127 first time)
        bcs @CheckRight         ; then skip left neighbor check; this is not lowest score
;
        sta ZP1                 ; left neighbor's score is lowest (so far)
        stx LowestScoreNode     ; so save it and the left node & check other neighbors
; ------------------------------------------------------------------
; Check RIGHT NEIGHBOR
; ------------------------------------------------------------------
;
@CheckRight:
        ldx NodeCurrent         ; restore original NodeCurrent
        lda NodeX,x 
        cmp GridXMax
        bcs @CheckTop
;
        inx                     ; point to right neighbor
        lda NodeScore,x 
        bmi @CheckTop
        cmp ZP1
        bcs @CheckTop
;
        sta ZP1
        stx LowestScoreNode
; ------------------------------------------------------------------
; Check TOP NEIGHBOR
; ------------------------------------------------------------------
;
@CheckTop:
        ldx NodeCurrent
        lda NodeY,x 
        beq @CheckBottom        ; saving a CMP to GridYMIN, since its 0 anyway
;
        txa                     ; NodeCurrent in ACC (for substraction)
        sec
        sbc GridWidth           ; GridWidth = 20, so NodeCurrent - 20 = node in row above
        tax                     ; put top neighbor node back in XREG
        lda NodeScore,x 
        bmi @CheckBottom
        cmp ZP1
        bcs @CheckBottom
;
        sta ZP1
        stx LowestScoreNode
; ------------------------------------------------------------------
; Check BOTTOM NEIGHBOR
; ------------------------------------------------------------------
;
@CheckBottom:
        ldx NodeCurrent
        lda NodeY,x 
        cmp GridYMax
        beq @CheckDone
;
        txa                     ; NodeCurrent in ACC (for addition)
        clc
        adc GridWidth           ; GridWidth = 20, so NodeCurrent + 20 = node in row below
        tax                     ; put bottom neighbor node back in XREG
        lda NodeScore,x 
        bmi @CheckDone
        cmp ZP1
        bcs @CheckDone
;
        sta ZP1                  ; this is not needed. ok to delete
        stx LowestScoreNode
; ------------------------------------------------------------------
; Check if done
; ------------------------------------------------------------------
;
@CheckDone:
        lda LowestScoreNode     ; which neighbor had the lowest score?
        cmp #$FF
        bne @CheckDone1
        lda #2                  ; if it was $FF, no path was found
@DoneOut:
        sta PathFound
        rts
@CheckDone1:
        inc PathIndex
        ldx PathIndex
        sta Path,x
        sta NodeCurrent
        tax 
        jmp @Loop1
.endproc

