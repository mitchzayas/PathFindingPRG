; -------------------------------------------------------
; Zero Page Definitions 
; -------------------------------------------------------
;
.ZEROPAGE
ZP1 = $06
tile_ptr =   $07
ZP4 = $09
ZP5 = $FA
ZP6 = $FB
ZP7 = $FC
ZP8 = $FD
ZP9 = $FF
ZP10= $E3
ZP11= $EB
ZP12= $EC
ZP13= $ED
ZP14= $EE
ZP2 = $EF
ZP3 = $CE
NodeCurrent = $CF
GRLO     =   $26
GRHI     =   $27
; -------------------------------------------------------
; Wave Propagation Definitions 
; -------------------------------------------------------
;
.DATA
.align 256
NodeScore:                          ; holds the distance from NodeGoal value for each node
        .res 240                    ; -1 = obstable; 0 = walkable; 1+ = score (i.e. node has been visited)
.align 256
NodeX:
        .res 240
.align 256
NodeY:
        .res 240
;
.align 256                          
NodeArray:                          ; node array to be evaluated
        .res 240
NodeArrayElementIndex:              ; 0-based index of max elements
        .res 1
NodeArrayElementCount:              ; count of elements in array (starts at 1)
        .res 1
;
.align 256
NeighborArray:                      ; neighbors found array
        .res 240
NeighArrayElementIndex:          ; 0-based index of max elements in neighbors array
        .res 1
NeighArrayElementCount:          ; count of elements in array (starts at 1)
        .res 1
;
GridWidth:                          ; used to find top & bottom neighbor
        .res 1
GridXMax:                           ; used to check right & bottom borders
        .res 1
GridYMax:
        .res 1
GridXMin:                           ; used to check top &left borders
        .res 1
GridYMin:
        .res 1
;
NodeGoal:                           ; destination goal from which the wave propagates
        .res 1
NodeStart:                          ; ode where the player is   
        .res 1
AlgoDone:                           ; exit algo flag (0 or 1)
        .res 1
reCalcFlag:
        .res 1
FLAG_Quit:
        .res 1
CursorOldPos:
        .res 1
CursorPos:
        .res 1
; -------------------------------------------------------
; Path Finding Definitions 
; -------------------------------------------------------
;
LowestScoreNode:
        .res 1
PathFound:
        .res 1
PathIndex:
        .res 1

.align 256
Path:
        .res 64
; -------------------------------------------------------
; Tile & HGR Definitions 
; -------------------------------------------------------
;
dummy: 
    .res 2           ;dummy address used for self-modyfying code
tileIndex: 
    .res 1
temp:
    .res 1

.RODATA
Empty:
    .byte   127,1,1,1,1,1,1,1
    .byte   1,1,1,1,1,1,1,127
    .byte   127,64,64,64,64,64,64,64
    .byte   64,64,64,64,64,64,64,127
Goal:
    .byte   127,1,97,49,25,25,25,25
    .byte   25,25,25,25,49,97,1,127
    .byte   127,64,67,70,76,76,64,64
    .byte   64,79,76,76,70,67,64,127
Start:
    .byte   127,1,113,121,25,25,25,121
    .byte   113,1,1,25,121,113,1,127
    .byte   127,64,71,79,76,64,64,71
    .byte   79,76,76,76,79,71,64,127

Green:
    .byte   127,1,41,41,41,41,41,41
    .byte   41,41,41,41,41,41,1,127
    .byte   127,64,69,69,69,69,69,69
    .byte   69,69,69,69,69,69,64,127
Blocked:
    .byte   127,127,127,127,127,127,127,127
    .byte   127,127,127,127,127,127,127,127
    .byte   127,127,127,127,127,127,127,127
    .byte   127,127,127,127,127,127,127,127
Cursor:
    .byte   127,1,1,1,1,1,65,65
    .byte   1,1,1,1,1,1,1,127
    .byte   127,64,64,64,64,64,65,65
    .byte   64,64,64,64,64,64,64,127


.align 256
TILES:
.word Empty, Goal, Start, Green, Blocked, Cursor

.align 256
HR1GRID_LO:
        .byte   $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$1C,$1E,$20,$22,$24,$26
        .byte   $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$1C,$1E,$20,$22,$24,$26
        .byte   $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$1C,$1E,$20,$22,$24,$26
        .byte   $00,$02,$04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$1C,$1E,$20,$22,$24,$26

        .byte   $28,$2A,$2C,$2E,$30,$32,$34,$36,$38,$3A,$3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E
        .byte   $28,$2A,$2C,$2E,$30,$32,$34,$36,$38,$3A,$3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E
        .byte   $28,$2A,$2C,$2E,$30,$32,$34,$36,$38,$3A,$3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E
        .byte   $28,$2A,$2C,$2E,$30,$32,$34,$36,$38,$3A,$3C,$3E,$40,$42,$44,$46,$48,$4A,$4C,$4E

        .byte   $50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62,$64,$66,$68,$6A,$6C,$6E,$70,$72,$74,$76
        .byte   $50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62,$64,$66,$68,$6A,$6C,$6E,$70,$72,$74,$76
        .byte   $50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62,$64,$66,$68,$6A,$6C,$6E,$70,$72,$74,$76
        .byte   $50,$52,$54,$56,$58,$5A,$5C,$5E,$60,$62,$64,$66,$68,$6A,$6C,$6E,$70,$72,$74,$76

.align 256
HR1GRID_HI:
        .byte   $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        .byte   $21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21
        .byte   $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
        .byte   $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23

        .byte   $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        .byte   $21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21
        .byte   $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
        .byte   $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23

        .byte   $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        .byte   $21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21,$21
        .byte   $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22
        .byte   $23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23,$23

HGRCOLS:
        .BYTE   $00,$00 ;COLOR 0 = BLACK1, EVEN COLUMN THEN ODD COLUMN
        .BYTE   $55,$2A ;COLOR 1 = VIOLET
        .BYTE   $2A,$55 ;COLOR 2 = GREEN
        .BYTE   $7F,$7F ;COLOR 3 = WHITE 1
        .BYTE   $80,$80 ;COLOR 4 = BLACK2
        .BYTE   $D5,$AA ;COLOR 5 = BLUE
        .BYTE   $AA,$D5 ;COLOR 6 = ORANGE
        .BYTE   $FF,$FF ;COLOR 7 = WHITE2