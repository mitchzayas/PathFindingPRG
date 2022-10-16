# Wave Propagation Pathfinding
This Apple II program demonstrates [wave propagation path finding](https://youtu.be/0ihciMKlcP8). The program was written in assembly using the [CC65 Cross Compiler](https://cc65.github.io). To run it in your favorite Apple II emulator, download the [WaveP Disk Image](/WaveP.DSK).

![Wave Propagation Program Screenshot](/WAVEP.png)

### Using the Program:
The program displays an empty grid consisting of 20 cells across and 12 cells down. One can move either the **Starting Cell** (S) or the **Goal Cell** (G) using the arrow keys and the path (in green) will automatically adjust to the new cell positions and around obstables. To toggle which cell you want to move, press "S" (or "G"), then use the arrow keys to move it around the grid. 

Additionally, pressing "C" toggles a cursor that can also be moved using the arrow keys, then pressing "O" places (or removes) an obstacle at the cursor's position. To quit the program, press "Q".

Controls:
* “G” mode allows one to move the goal tile using the arrow keys (default)
* “S” mode moves the start tile using the arrow keys
* “C” mode reveals the cursor that can be moved with the arrow keys
  * “O” toggles an obstacle at the cursor position (removes an obstacle if one is there already)
* “Q” quits the program

### How it works:
There are two main components in this program:
* A graphics tile engine
* Wave propagation algorithm and pathfinding routines

These components are independent of each other, with the tile engine only there to demonstrate (visually) the pathfinding routines.

### Graphics tile engine:
This was inspired by [Pixinn](https://github.com/Pixinn) (Christophe Meneboeuf) who does a fantastic job of laying out all the principles of creating a tile engine for the Apple II in [his blog](https://www.xtof.info/an-hires-tile-engine-for-the-apple-ii.html).

Essentially, the hires graphics page is divided into a grid of 20 cells across by 12 cells down (240 cells total). This means each cell is 2 bytes across (14 pixels in total) and 16 bytes down for a total of 32 bytes per cell.

I use two lookup tables (one for the hi-bytes of the addresses and one for the lo-bytes) to point to the top-left byte in each cell. From there, I use math (and knowledge of the Apple II’s “amazing” [HGR address layout](https://www.xtof.info/hires-graphics-apple-ii.html)) to access the remaining bytes in the cell. 

[add screenshot of the lookup tables here]

In the tilesGraphics.asm file, the subroutine called drawTile blasts 32 bytes of tile data to HGR page 1 (tile definitions are in the inits.asm file). Note, drawTile is fairly “unrolled” and leverages self-modifying code for speed. All we have to do is pass the cell number (0-239) to drawTile in the X-register and the tile number (0-5) in the accumulator. Many more tiles can be defined, but I only needed 6 for this demo.
