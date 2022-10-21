;check keyboard and return with 0 in YREG if no key pressed
;return with 1 in YREG if Keypress and Key Value in ACC
.proc keyin       
        LDA $C000           ;read keyboard
        BMI keypull         ;if >127 then key was pressed, go pull it 
        ldy #0              ;no keypress so return 0 in YREG
        RTS
keypull:
        STA $C010           ;clear the strobe so its ready for next keypress
        ldy #1              ;key was pressed so signal in YREG; ACC contains value
        RTS
.endproc

; -------------------------------------------------------
; This subroutine checks which key was pressed and 
; distributes work accordingly
;
; enter with: keypress value in ACC
; exit with: -
; -------------------------------------------------------
;
.proc kbHandler
        cmp #209                ; check if Q ASCII value was pressed (quit)
        beq @Quit
        cmp #241                ; check if q ASCII value was pressed (quit)
        bne @Check11
@Quit:
        lda #1
        sta FLAG_Quit           ; signal to exit program
@Done:
        rts
;
@Check11:
        cmp #211                ; check if S ASCII value was pressed (start)
        beq @Check22
        cmp #243                ; check if s ASCII value was pressed (start)
        bne @Check2
;
@Check22:
        lda #<moveStart          ; change the default to "Move Start SubRoutine"
        sta kbSubHandler+1
        lda #>moveStart
        sta kbSubHandler+2
;
        ldx CursorPos
        lda NodeScore,x 
        jsr eraseTile
        jsr erasePath
        lda #1
        sta reCalcFlag
;
        jmp @Done
;
@Check2:
        cmp #195                ; check if C ASCII value was pressed (cursor)
        beq @Check33
        cmp #227                ; check if c ASCII value was pressed (cursor)
        bne @Check3
;
@Check33:
        lda #<moveCursor          ; change the default to "Move Cursor SubRoutine"
        sta kbSubHandler+1
        lda #>moveCursor
        sta kbSubHandler+2
;
        ldx CursorPos
        stx CursorOldPos
        lda #5
        jsr drawTile
        jsr erasePath
        lda #1
        sta reCalcFlag
        jmp @Done
;
@Check3:
        cmp #199                ; check if G ASCII value was pressed (goal)
        beq @Check44 
        cmp #231                ; check if g ASCII value was pressed (goal)
        bne @Done               
;
@Check44:
        lda #<moveGoal          ; change the default to "Move Goal SubRoutine"
        sta kbSubHandler+1
        lda #>moveGoal
        sta kbSubHandler+2
;
        ldx CursorPos
        lda NodeScore,x 
        jsr eraseTile
        jsr erasePath
        lda #1
        sta reCalcFlag
        jmp @Done
;
.endproc

; -------------------------------------------------------
; This subroutine calls the toggled action (G, C, S)
; that is patched in here with self-modifying code.
; Be sure to set G as the default action in the init!!!
;
; enter with: kbHandler (or default in init) set subRoutine address
; exit with: -
; -------------------------------------------------------
;
.proc kbSubHandler
        jsr $0000            ; self-modifying code sets this address
        rts
.endproc

; -------------------------------------------------------
; moveGoal
; exit with: -
; -------------------------------------------------------
;
.proc moveGoal
        ldx NodeGoal        ; load the NodeGoal value
        stx ZP14        
        cmp #136            ; was left arrow key pressed?
        bne @checkRight
;        
        lda NodeX,x         
        beq @out            ; can't move left if NodeX = 0
        dex                 ; we're going left
        cpx NodeStart       
        beq @out            ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out            ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeGoal        ; We can move! Store the new nodeGoal value
        jsr erasePath
        ldx ZP14
        lda #0
        jsr eraseTile
        lda #1
        sta reCalcFlag
        jmp @out
@checkRight:
        cmp #149
        bne @checkUp
;        
        ldx NodeGoal        ; load the NodeGoal value
        lda NodeX,x         
        cmp GridXMax
        bcs @out            ; can't move if NodeX >=39
        inx                 ; we're going right
        cpx NodeStart       
        beq @out            ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out           ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeGoal        ; We can move! Store the new nodeGoal value
        jsr erasePath
        ldx ZP14
        lda #0
        jsr eraseTile
        lda #1
        sta reCalcFlag
        jmp @out
@out:
        jmp @ddone
@checkUp:
        cmp #139
        bne @checkDown
;        
        ldx NodeGoal        ; load the NodeGoal value
        lda NodeY,x         
        beq @out            ; can't move if NodeY = 0
        txa 
        sec 
        sbc GridWidth
        tax
        cpx NodeStart       
        beq @out            ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out            ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeGoal        ; We can move! Store the new nodeGoal value
        jsr erasePath
        ldx ZP14
        lda #0
        jsr eraseTile
        lda #1
        sta reCalcFlag
        jmp @out
@checkDown:
        cmp #138
        bne @out
;        
        ldx NodeGoal        ; load the NodeGoal value
        lda NodeY,x         
        cmp GridYMax
        bcs @out            ; can't move if NodeY = 0
        txa 
        clc 
        adc GridWidth
        tax
        cpx NodeStart       
        beq @out            ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out            ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeGoal        ; We can move! Store the new nodeGoal value
        jsr erasePath
        ldx ZP14
        lda #0
        jsr eraseTile
        lda #1
        sta reCalcFlag
;
@ddone:
        rts
.endproc

; -------------------------------------------------------
; moveStart
; exit with: -
; -------------------------------------------------------
; -------------------------------------------------------

;
.proc moveStart
        cmp #136                ; was left arrow key pressed?
        bne @checkRight
;        
        ldx NodeStart           ; load the NodeGoal value
        stx ZP14
        lda NodeX,x         
        beq @out                ; can't move left if NodeX = 0
        dex                     ; we're going left
        cpx NodeGoal       
        beq @out                ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out                ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeStart           ; We can move! Store the new nodeGoal value
        jsr erasePath
        lda #1
        sta reCalcFlag
        jmp @out
@checkRight:
        cmp #149
        bne @checkUp
;        
        ldx NodeStart           ; load the NodeGoal value
        lda NodeX,x         
        cmp GridXMax
        bcs @out                ; can't move if NodeX >=39
        inx                     ; we're going right
        cpx NodeGoal       
        beq @out                ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out                ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeStart           ; We can move! Store the new nodeGoal value
        jsr erasePath
        lda #1
        sta reCalcFlag
        jmp @out
@out:
        jmp @ddone
@checkUp:
        cmp #139
        bne @checkDown
;        
        ldx NodeStart           ; load the NodeGoal value
        lda NodeY,x         
        beq @out                ; can't move if NodeY = 0
        txa 
        sec 
        sbc GridWidth
        tax
        cpx NodeGoal       
        beq @out                ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out                ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeStart           ; We can move! Store the new nodeGoal value
        jsr erasePath
        lda #1
        sta reCalcFlag
        jmp @out
@checkDown:
        cmp #138
        bne @out
;        
        ldx NodeStart           ; load the NodeGoal value
        lda NodeY,x         
        cmp GridYMax
        bcs @out                ; can't move if NodeY = 0
        txa 
        clc 
        adc GridWidth
        tax
        cpx NodeGoal       
        beq @out                ; can't move if NodeStart is there
        lda NodeScore,x     
        bmi @out                ; can't move if NodeScore is negative (i.e. obstable)
        stx NodeStart           ; We can move! Store the new nodeGoal value
        jsr erasePath
        lda #1
        sta reCalcFlag
;
@ddone:
        rts
.endproc


; -------------------------------------------------------
; moveCursor
; exit with: -
; -------------------------------------------------------
;
.proc moveCursor
        cmp #207                ; was "O" pressed (i.e. obstacle toggle)
        beq @CheckO
        cmp #239                ; was "o" pressed (i.e. obstacle toggle)
        bne @checkLeft
;
@CheckO:
        ldx CursorPos           ; which grid node is the cursor at?
        lda NodeScore,x 
        cmp #$FF                ; if negative, this node is blocked
        beq @ObstacleClear      ; so go clear it
; there's no obstacle so let's toggle it on
        lda #$FF                ; if not blocked, then its clear
        sta NodeScore,x         ; so let's set it as an obstacle
        lda #4                  ; this points to the obstacle tile
        jsr drawTile            ; XREG already points to node
        jsr erasePath
        lda #1
        sta reCalcFlag
@Done:
        rts 
@ObstacleClear:
        lda #0
        sta NodeScore,x 
        jsr drawTile            ; 0 = empty tile; XREG points to node
        jsr erasePath
        lda #1
        sta reCalcFlag
        jmp @Done
; -------------------------------------------------------
@checkLeft:
        cmp #136            ; was left arrow key pressed?
        bne @checkRight
;        
        ldx CursorPos       ; load the CursorPos value
        lda NodeX,x         
        beq @out            ; can't move left if NodeX = 0
        dex                 ; we're going left
        cpx NodeGoal       
        beq @out            ; can't move if NodeGoal is there
        cpx NodeStart     
        beq @out            ; can't move if NodeStart is there
        stx CursorPos       ; We can move! Store the new nodeGoal value
        jmp @ddone
@checkRight:
        cmp #149
        bne @checkUp
;        
        ldx CursorPos
        lda NodeX,x         
        cmp GridXMax
        bcs @out            ; can't move if NodeX >=39
        inx                 ; we're going right
        cpx NodeGoal       
        beq @out            ; can't move if NodeGoal is there
        cpx NodeStart     
        beq @out            ; can't move if NodeStart is there
        stx CursorPos       ; We can move! Store the new nodeGoal value
        jmp @ddone
@ddone:
; -------------------------------------------------------
;There was a cursor move, so erase it from old Pos,
;and put it in new Pos
; -------------------------------------------------------
        ldx CursorOldPos
        lda NodeScore,x 
        jsr eraseTile
;
        ldx CursorPos
        stx CursorOldPos
        lda #5
        jsr drawTile
;
        lda #1
        sta reCalcFlag

@out:
        rts
@checkUp:
        cmp #139
        bne @checkDown
;        
        ldx CursorPos       
        lda NodeY,x         
        beq @out            ; can't move if NodeY = 0
        txa 
        sec 
        sbc GridWidth
        tax
        cpx NodeGoal       
        beq @out            ; can't move if NodeGoal is there
        cpx NodeStart     
        beq @out            ; can't move if NodeStart is there
        stx CursorPos       ; We can move! Store the new nodeGoal value
        jmp @ddone
@checkDown:
        cmp #138
        bne @out
;        
        ldx CursorPos        ; load the NodeGoal value
        lda NodeY,x         
        cmp GridYMax
        bcs @out            ; can't move if NodeY = 0
        txa 
        clc 
        adc GridWidth
        tax
        cpx NodeGoal       
        beq @out            ; can't move if NodeGoal is there
        cpx NodeStart     
        beq @out            ; can't move if NodeStart is there
        stx CursorPos       ; We can move! Store the new nodeGoal value
        jmp @ddone
.endproc



