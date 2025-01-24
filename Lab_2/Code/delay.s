.section .text
.global sleep_one_second

sleep_one_second:
    PUSH {r4, r5, lr}      @ Save registers and return address

    LDR r4, =1000000       @ Load 1,000,000 (1 MHz clock, 1 second delay)
loop_outer:
    SUBS r4, r4, #1        @ Decrement outer loop counter
    BNE loop_outer         @ If not zero, keep looping

    POP {r4, r5, lr}       @ Restore registers and return address
    BX lr                  @ Return to caller