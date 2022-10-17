# Wave Propagation Pathfinding
This Apple II program demonstrates [wave propagation path finding](https://en.wikipedia.org/wiki/Wavefront_expansion_algorithm). The program was written in assembly using the [CC65 Cross Compiler](https://cc65.github.io). To run it in your favorite Apple II emulator, download the [WaveP Disk Image](/WaveP.DSK).

![Wave Propagation Program Screenshot](/Path_Screenshot.png)

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

In the tilesGraphics.asm file, the subroutine called drawTile blasts 32 bytes of tile data to HGR page 1 (tile definitions are in the inits.asm file). Note, drawTile is fairly “unrolled” and leverages self-modifying code for speed. All we have to do is pass the cell number (0-239) to drawTile in the X-register and the tile number (0-5) in the accumulator. Many more tiles can be defined, but I only needed 6 for this demo.

### Casting a wave:

[Javidx9’s video on wave propagation path finding](https://youtu.be/0ihciMKlcP8) provides a clear, step-by-step explanation of the algorithm. I recommend you view his video, as it will help you follow the code. By the way, don’t be intimidated by the word “algorithm” as it’s just a repeatable process. Think of it as a sequence of steps that are repeated over and over again until an outcome is achieved.

I followed Javidx9’s method fairly faithfully, casting a wave by utilizing two arrays, NodeArray and NeighborArray in the waveP.asm file, as he describes. The difference in my approach is that I scored the neighbor cells when they were found, ensuring I never had to contend with duplicate cells in the array.

Wave Propagation Algorithm:
1. Initialize every cell in the grid to a score of 0
    * Score of 0 means walkable
    * Score of -1 means a non-walkable obstacle (note, -1 = 255 = $FF in hex)
    * Score >=1 is the cell’s score, meaning how far away it is from the goal cell
2. Start at the goal cell. This is the “current cell”. Add it to the NodeArray and give it a score of 1. 
3. Find the current cell’s neighbors to the east, west, north and south. The score for these cells is current cell’s score +1
    * Add each neighbor to the NeighborArray if:
        * It is within the grid’s borders
        * It has a score of 0 (walkable). In other words:
            * It does not have a score of -1 ($FF), indicating its an obstacle
            * It does not have a score >= 1, indicating we scored it already
    * If no neighbor cells were found, then the wave processed every cell in the 240 cell grid and the algorithm is done. Exit!
4. Remove the current cell from the NodeArray, since we’ve processed it. If there are other cells in NodeArray (there will be in subsequent passes), loop through each of them until NodeArray is empty (i.e. go back to step 3) 
5. Transfer each cell in the NeighborArray to the NodeArray. NeighborArray is now empty. Go back to step 3.

### Follow the path:
Once we have each cell in the grid scored based on its distance to the goal cell, we use the FindPath subroutine in the optimalPath.asm file to fill an array called Path.

The first element added to this array is the start cell. It then looks at the scores for the east, west, north and south neighbors, picking the one with the lowest score. This cell then gets added to the Path array and the process repeats until the goal cell is reached.

If the goal cell, start cell or an obstacle is added (or removed) from the grid, the program casts a new wave and rescores each cell once again, then we rerun FindPath.

### The bottom line:
So what can this be used for, you ask? In a game, these subroutines can allow an NPC to follow a path towards a desired location on the screen or to the main player character (think [The Terminator](https://en.wikipedia.org/wiki/The_Terminator), relentlessly hunting its prey).

The routine that casts the wave takes ~5,700 cycles and the routine that finds a path takes ~4,000 cycles, so they are, perhaps, fast enough to run in real-time as players and desired locations move around.

Separately, once the wave is cast and the grid is scored, one or more NPCs can leverage the scores data to find paths, meaning it can serve a large number non-player characters (i.e. a Path array for each desired NPC).
