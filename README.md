# Tetrisito
## Description
A simple Tetris clone for a class project using MIPS assembly.
It tells whether a 6x6 end grid is possible given a 6x6 initial grid and up to 5 Tetris pieces with line clear.

The Python file can drop pieces in random order and move the pieces side to side as they are falling
The Assembly file drops pieces sequentially and can only drop pieces straight down from the top.

## Input file format
Arrangement of start grid. ( '.' represents an empty cell, '#' represents an occupied cell)
Arrangement of final grid. ( '.' represents an empty cell, '#' represents an occupied cell)
Number of pieces (1 to 5)
Pieces
