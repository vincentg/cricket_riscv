# cricket_riscv
A Dart Cricket game scorer in RISC-V Assembly language

Example of game display and a turn from Player 1:
 - Dart 1: closing 19 with a double
 - Dart 2: scoring 19,
 - Dart 3 : hit non closed 18: 
```
 Player 1       |  | Player 2
        /       |20|    O
        /       |19|    -
        -       |18|    O
        X       |17|    -
        -       |16|    -
        -       |15|    -
 Score: 0       |  | Score: 18
Player 1 Turn
Enter Dart 1:
d19
 Player 1       |  | Player 2
        /       |20|    O
        O       |19|    -
        -       |18|    O
        X       |17|    -
        -       |16|    -
        -       |15|    -
 Score: 0       |  | Score: 18
Enter Dart 2:
19
 Player 1       |  | Player 2
        /       |20|    O
        O       |19|    -
        -       |18|    O
        X       |17|    -
        -       |16|    -
        -       |15|    -
 Score: 19      |  | Score: 18
Enter Dart 3:
18
 Player 1       |  | Player 2
        /       |20|    O
        O       |19|    -
        /       |18|    O
        X       |17|    -
        -       |16|    -
        -       |15|    -
 Score: 19      |  | Score: 18
Player 2 Turn
Enter Dart 1:
```
