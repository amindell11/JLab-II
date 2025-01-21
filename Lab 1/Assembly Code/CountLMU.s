@ Define my Raspberry Pi
        .cpu    cortex-a53
        .fpu    neon-fp-armv8
        .syntax unified         @ modern syntax

@ Useful source code constants
        .equ    STDIN,0
        .equ    STDOUT,1
        .equ    aLetter,-16
        .equ    local,16

@ Constant program data
        .section  .rodata
        .align  2
promptMsg:
        .asciz   "Please type text of 15 characters: "
        .equ    promptLngth,.-promptMsg
responseMsg:
        .asciz   " instances of LMU\n"
        .equ    responseLngth,.-responseMsg


@ Program code
        .text
        .align  2
        .global main
        .type   main, %function
main:
        sub     sp, sp, 8       @ space for fp, lr
        str     fp, [sp, 0]     @ save fp
        str     lr, [sp, 4]     @   and lr
        add     fp, sp, 4       @ set our frame pointer
        sub     sp, sp, local   @ allocate memory for local var

        mov     r0, STDOUT      @ prompt user for input
        ldr     r1, promptMsgAddr
        mov     r2, promptLngth
        bl      write


        mov     r0, STDIN       @ from keyboard
        add     r1, fp, aLetter @ address of aLetter
        mov     r2, 15           @ one char
        bl      read

        mov     r0, STDOUT      @ echo user's character
        add     r1, fp, aLetter @ address of aLetter
        mov     r2, 15           @ one char
        bl      write
        
        add r1, fp, aLetter
        bl count_LMU
        
        
        mov     r0, STDOUT      @ nice message for user
        LDR R1, =response
        mov R2, 1
        bl write
        
        ldr     r1, responseMsgAddr
        mov     r2, responseLngth
        bl      write
        
        b main
count_LMU: 
        PUSH {R3} @ Save R3 and R4 on the stack 

        MOV R2, #0 @ Initialize count to 0 
        LDR R3, =response
        str R2, [R3]
        LDRB R3, [R1], #1 @ Load the first character of the string and increment R1
loop: 
        CMP R3, #0 @ Check if the end of the string (null terminator) 
        BEQ done @ If end, exit loop
L: 
        CMP R3, #'L' @ Check if the current character is 'L' 
        BNE next_char @  If not, go to next character 
        LDRB R3, [R1], #1 @ Load next character 
        CMP R3, #'M' @ Check if it is 'M' 
        BNE L @ If not, go back and check for L 
        LDRB R3, [R1], #1 @ Load next character 
        CMP R3, #'U' @ Check if it is 'U' 
        BNE L @ If not, go back and check for L 
        ADD R2, R2, #1 @ Increment count
next_char: 
        LDRB R3, [R1], #1 @ Load the next character and increment R1 
    B loop @ Repeat the loop
done: 
        add R2, R2, #48 @ convert count to ascii
        LDR R3, =response
        str R2, [R3]
        POP {R3} @ Restore R3 and R4 from the stack
        BX LR                   @ Return from the function
@ Addresses of messages
        .align  2
promptMsgAddr:
        .word   promptMsg
responseMsgAddr:
        .word   responseMsg

.section .bss
        .align 2
        response:
                .space 4
