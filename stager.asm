WRVEC       = $03D0; Warm Re-entry Vector
START:      JMP MAIN
.include "src/PathFindingPRG/main.asm"

.CODE
MAIN:
            jsr gameLoop
            rts
.END