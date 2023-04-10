# Score Darts Cricket Game for Two Players

# Register usage:
# 
# a0/a1/a2/a7 = ABI Calls
# 

.option arch, rv64imafdcv
.option pic

.data
playerturn: .ascii "Player 1 Turn\n"
.equ playerturn_len, 14
.equ playerid_pos, 7
# scores for 20 19 18 17 16 15
prompt:  .ascii "Welcome to Cricket scorer!\n"
.equ prompt_len, 27
gamestate: .ascii " Player 1\t|  | Player 2\t\n\t-\t|20|\t-\t\n\t-\t|19|\t-\t\n\t-\t|18|\t-\t\n\t-\t|17|\t-\t\n\t-\t|16|\t-\t\n\t-\t|15|\t-\t\n"
.equ gamestate_len, 91
dartprompt: .ascii "Enter Dart 1:\n"
.equ dartprompt_len, 14
.equ dartnum_pos, 11
input_buffer: .byte 0,0,0,0
p1score: .word 0
p2score: .word 0
# state for 15 16 17 18 19 20 (must reach 3 to score)
# Hits left to close
p1closing: .byte 3,3,3,3,3,3
p2closing: .byte 3,3,3,3,3,3
.equ closing_len, 6
displaychar: .ascii "OX/"
invalidinput: .ascii "Error: Invalid input, please retry (ENTER for out, <num> for number between 15 and 20\n d<num> for double\n t<num> for triples\n\n"
.equ invalidinput_len, 126

# Start of constants
.equ stdin_fd, 0
.equ stdout_fd, 1
.equ read_syscall, 63
.equ write_syscall, 64

#Start of Macros
.macro print addr len
li a0, stdout_fd
la a1, \addr
li a2, \len
li a7, write_syscall
ecall
.endm



.text
.globl _start

_start:
    print prompt prompt_len+gamestate_len
    li a4, 0 # Player id (0 idx)
  
    turn_start:
        li a5, 0 # Dart Num  (0 idx)
        li t0, '1' 
        add a3, t0, a4 # a3 <- '1' + playerid (a4)
        la a1, playerturn 
        sb a3, playerid_pos(a1) #Override playerId
        print playerturn, playerturn_len

        dart_start:    
            li t0, '1' 
            add a3, t0, a5 # a3 <- '1' + dartId (a5)
            la a1, dartprompt
            sb a3, dartnum_pos(a1) #Override dartId in msg
            print dartprompt dartprompt_len

            li a0, stdin_fd
            la a1, input_buffer
            li a2, 4 #Read 4 bytes
            li a7, read_syscall
            ecall
            # a0 = num read
            # a1 contain read bytes

            # case 1, 1 byte read (ENTER)
            li a2,1
            beq a0,a2,next_dart

            # case 2, 2 byte read (invalid)
            addi a2,a2,1
            beq a0,a2,invalid_entry
            
            # Start of valid input, init mult ratio to 1
            li t1, 1
            # case 3, 3 byte read (accept number 15-20)
            addi a2,a2,1
            beq a0,a2,read_number
            
            # case 4, 4 byte read (d<num> , t<num>)
            lb a0,(a1)
            addi a1,a1,1 # Move a1 1 byte forward
            li a2, 't'
            beq a0,a2,set_triple  # First letter = 't'
            li a2, 'd'
            beq a0,a2,set_double  # Fist letter = 'd'
            j invalid_entry # nor t or d

            set_triple:
            li t1,3
            j read_number

            set_double:
            addi t1,t1,1

            read_number:
            li t0, '0' 
            #Extract first digit
            lb t3, 0(a1)
            sub a6, t3, t0 
            # Multiply first digit by 10
            li t3,10
            mul a6,a6,t3
            #Extract second digit
            lb t3, 1(a1)
            sub t3,t3,t0
            # ADD both digits. result in a6
            add a6,a6,t3
            # Accept only numbers 15 > N <= 20
            li t0,21
            bge a6,t0,invalid_entry
            li t0,15
            blt a6,t0,invalid_entry

            # t1 contains multiplier (1,2,3), a6 number between 0-20"
            sub a6,a6,t0 #substract 15 to get offset to confirm if number is closed
            # Load closing state for current player
            li t0, closing_len
            mul t0,t0,a4
            la a2, p1closing
            add a2,a2,t0 # Add player offset
            add a2,a2,a6 # Add dart score offset
            lb a1, (a2)

            li t2,1 # Check if number is closed
            bge a1,t2,update_closing
            # Number is closed by current player, check other player
            # Get other player offset ( if a4 is 0, other player is 1, else 0)
            xori a3,a4,1
            li t0, closing_len
            mul t0,t0,a3
            la t3, p1closing
            add t3,t3,t0 # Add player offset
            add t3,t3,a6 # Add dart score offset
            lb t4, (t3)  # Load other player closing state
            blt t4,t2,next_dart # Other player closed number, no-score
            # SCORING POINTS! Player have closed num, oponent don't
            # Get player offset 
            slli t3,a4,2
            la t2, (p1score)
            add t2,t2,t3
            lw  a7, (t2)  # Get current player score
            addi a6,a6,15 # Add 15 back to dart offset 
            mul a6,a6,t1  # Multiply by double/triple
            add a7,a7,a6  # ADD To score
            sw  a7, (t2)  # Save score in memory
            j next_dart
                      

            update_closing:
            # Substract hit ratio and overwrite
            sub a1,a1,t1
            sb a1, 0(a2)
            j next_dart
         

            invalid_entry:
            # invalid entry, print error and redo input
            print invalidinput, invalidinput_len
            j dart_start

            next_dart:
                li t0,2 
                beq a5,t0,next_player # 3 Darts per player
                addi a5,a5,1
                j dart_start

            next_player:
                xori a4,a4,1
                j turn_start
                
                
            

    #SHOW GameState at end of turn
    li a0, 1 #stdout
    lla a1, gamestate
    li a2, 91 # length of prompt
    li a7, 64 
    ecall

    # exit program. add exit(0) syscall here
    


