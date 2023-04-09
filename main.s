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
p1scores: .word 0,0,0,0,0,0
p2scores: .word 0,0,0,0,0,0
# state for 20 19 18 17 16 15 (must reach 3 to score)
# Hits left to close
p1closing: .byte 4,4,4,4,4,4
p2closing: .byte 4,4,4,4,4,4
displaychar: .ascii "OX/ "
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
    li a5, 0 # Dart Num  (0 idx)
  
    turn_start:
        li t0, '1' 
        add a3, t0, a4 # a3 <- '1' + playerid (a4)
        la a1, playerturn 
        sb a3, playerid_pos(a1) #Override playerId
        print playerturn, playerturn_len

        dart_start:    
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
            # t1 contains multiplier (1,2,3), a1 "<dgt><dgt>\n"
            ebreak
            

            invalid_entry:
            # invalid entry, print error and redo input
            print invalidinput, invalidinput_len
            j dart_start

            update_score:

            next_dart:
                addi a5,a5,1
                j dart_start
            

    #SHOW GameState at end of turn
    li a0, 1 #stdout
    lla a1, gamestate
    li a2, 91 # length of prompt
    li a7, 64 
    ecall

    # exit program. add exit(0) syscall here
    


