# Score Darts Cricket Game for Two Players

# Register usage:
# 
# a0/a1/a2/a7 = ABI Calls
# 

.option arch, rv64imafdcv
.option pic

.data
playerturn: .ascii "Player 1 Turn\n"
# scores for 20 19 18 17 16 15
prompt:  .ascii "Welcome to Cricket scorer!\n"
gamestate: .ascii " Player 1\t|  | Player 2\t\n\t-\t|20|\t-\t\n\t-\t|19|\t-\t\n\t-\t|18|\t-\t\n\t-\t|17|\t-\t\n\t-\t|16|\t-\t\n\t-\t|15|\t-\t\n"
dartprompt: .ascii "Enter Dart 1:\n"
input_buffer: .dword 0
p1scores: .word 0,0,0,0,0,0
p2scores: .word 0,0,0,0,0,0
# state for 20 19 18 17 16 15 (must reach 3 to score)
# Hits left to close
p1closing: .byte 4,4,4,4,4,4
p2closing: .byte 4,4,4,4,4,4
displaychar: .ascii "OX/ "


.text
.globl _start

_start:
    li a0, 1 #stdout
    la a1, prompt
    li a2, 27+91 # length of prompt + length of gamestate
    li a7, 64 
    ecall
    li a4, 50
    li a5, 1
  
    turn_start:
        la a5,playerturn #offset of player number
        sb a4,7(a5)
        li a0, 1 #stdout
        la a1,playerturn
        li a2, 20
        li a7, 64
        ecall
    


    #SHOW GameState at end of turn
    li a0, 1 #stdout
    lla a1, gamestate
    li a2, 91 # length of prompt
    li a7, 64 
    ecall

    # initialize player scores to 0
    li x2, 0
    li x3, 0
    
    # loop for 20 rounds
    li x8, 20
    score_loop:
        # reset dart scores to 0
        li x4, 0
        li x5, 0
        li x6, 0
        
        # read input from user
        li x11, 0
        read_input:
            # read a character
            ecall
            mv x9, a0
            li t1, 0 
            # check for end of input
            beq x9, t1, input_done
            
            # check for prefix character
            li t1, 100
            beq x9, t1, set_double
            li t1, 116
            beq x9, t1, set_triple
            
            # convert character to number
            li x1, 10
            li t1, 48
            sub x9, x9, t1 
            
            # add to current dart score
            beq x11, x0, set_dart1
            li t1, 1
            beq x11, t1, set_dart2
            addi t1,t1,1
            beq x11, t1, set_dart3
            
            set_dart1:
                sll x4, x4, x1
                add x4, x4, x9
                j input_next
            
            set_dart2:
                sll x5, x5, x1
                add x5, x5, x9
                j input_next
            
            set_dart3:
                sll x6, x6, x1
                add x6, x6, x9
                j input_next
                
            set_double:
                li x12, 2
                j input_next
                
            set_triple:
                li x12, 3
            
            input_next:
                addi x11, x11, 1
                j read_input
            
        input_done:
        
        # calculate dart score
        add x7, x4, x5
        add x7, x7, x6
        mul x7, x7, x12
        
        # update player score
        beq x2, x0, p2_turn
        add x2, x2, x7
        j score_done
        
        p2_turn:
            add x3, x3, x7
            
        score_done:
            addi x8, x8, -1
            bne x8, x0, score_loop
            
    # exit program
    li a0, 10


