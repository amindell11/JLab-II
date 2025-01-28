.global _start

.equ DISPLAY_BASE, 0xFF200020      @ Base address for the seconds and minutes display
.equ DISPLAY_HOURS_BASE, 0xFF200024  @ Base address for the hours display

_start:
    MOV r0, #0                @ Initialize seconds counter to 0
    MOV r6, #0                @ Initialize minutes counter to 0
    MOV r7, #0                @ Initialize hours counter to 0

count_loop:
    CMP r0, #60               @ Check if the seconds counter has reached 60
    BNE check_minutes         @ If not, check minutes

    ADD r6, r6, #1            @ Increment minutes counter
    MOV r0, #0                @ Reset the seconds counter

check_minutes:
    CMP r6, #60               @ Check if the minutes counter has reached 60
    BNE check_hours           @ If not, check hours

    ADD r7, r7, #1            @ Increment hours counter
    MOV r6, #0                @ Reset the minutes counter

check_hours:
    CMP r7, #24               @ Check if the hours counter has reached 24
    BNE continue_count        @ If not, continue counting

    MOV r7, #0                @ Reset the hours counter

continue_count:
    PUSH {r0}                 @ Save the current seconds counter value

    @ Calculate seconds for the display
    BL get_led_code           @ Call the subroutine to calculate display value
    MOV r5, r1                @ Store the seconds display code in r5

    @ Calculate minutes for the display
    MOV r0, r6                @ Load the minutes counter into r0
    BL get_led_code           @ Call the subroutine to calculate display value
    LSL r1, r1, #16           @ Shift the minutes display code left by 16 bits
    ORR r1, r1, r5            @ Combine minutes and seconds into r1

    @ Write seconds and minutes to the first display word
    LDR r3, =DISPLAY_BASE     @ Load the base address for the seconds/minutes display
    STR r1, [r3]              @ Write the combined value to the display

    @ Calculate hours for the display
    MOV r0, r7                @ Load the hours counter into r0
    BL get_led_code           @ Call the subroutine to calculate display value

    @ Write hours to the second display word
    LDR r3, =DISPLAY_HOURS_BASE @ Load the base address for the hours display
    STR r1, [r3]              @ Write the hours value to the display

    POP {r0}                  @ Restore the seconds counter value

    BL sleep_one_second       @ Pause for 1 second
    ADD r0, r0, #1            @ Increment the seconds counter
    B count_loop              @ Repeat the loop


sleep_one_second:
    PUSH {r4, r5, lr}      @ Save registers and return address

    LDR r4, =0x00001000      @ Load 1,000,000 (1 MHz clock, 1 second delay)
loop_outer:
    SUBS r4, r4, #1        @ Decrement outer loop counter
    BNE loop_outer         @ If not zero, keep looping

    POP {r4, r5, lr}       @ Restore registers and return address
    BX lr                  @ Return to caller




@ Subroutine to calculate the seven-segment display value
get_led_code:
    PUSH {r4, lr}                 @ Save return address

    BL divide_by_10               @ Call the division subroutine
    @ After the call:
    @ r1 = tens digit (quotient)
    @ r0 = ones digit (remainder)

    @ Convert the ones digit to seven-segment code
    MOV r2, r1                    @ Move tens digit to r2
    BL number_to_segments         @ Call the function to get the segment code
    MOV r4, r1                    @ Store converted ones digit in R4

    @ Convert the tens digit to seven-segment code
    MOV r0, r2
    BL number_to_segments         @ Call the function to get the segment code
    LSL r1, r1, #8                @ Shift the tens digit value left by 8 bits

    @ Combine tens and ones digits into a single word
    ORR r1, r1, r4                @ Combine tens (shifted) and ones into r1

    POP {r4, lr}                  @ Restore return address
    BX lr                         @ Return to caller

divide_by_10:
    PUSH {lr}                 @ Save return address
    MOV r2, #10               @ Divisor (10)
    MOV r1, #0                @ Initialize quotient (r1) to 0

divide_loop:
    CMP r0, r2                @ Compare dividend (r0) with divisor (10)
    BLT end_divide            @ If dividend < 10, stop the division
    SUB r0, r0, r2            @ Subtract 10 from the dividend
    ADD r1, r1, #1            @ Increment quotient
    B divide_loop             @ Repeat the loop

end_divide:
    @ At this point:
    @ r1 = quotient (tens digit)
    @ r0 = remainder (ones digit)
    POP {lr}                  @ Restore return address
    BX lr                     @ Return to caller


number_to_segments:
    PUSH {lr}                    @ Save return address
    CMP r0, #9                   @ Check if the number is greater than 9
    BHI invalid_input            @ Branch if invalid input

    LDR r1, =segment_table       @ Load the address of the lookup table
    LDRB r1, [r1, r0]            @ Load the binary value for the number (indexed by r0)
    B return_value               @ Skip invalid case

invalid_input:
    MOV r1, #0                   @ Set r1 to 0 for invalid input (no segments lit)

return_value:
    POP {lr}                     @ Restore return address
    BX lr                        @ Return to caller

.align 2
segment_table:
    .byte 0x3F                   @ Binary for 0
    .byte 0x06                   @ Binary for 1
    .byte 0x5B                   @ Binary for 2
    .byte 0x4F                   @ Binary for 3
    .byte 0x66                   @ Binary for 4
    .byte 0x6D                   @ Binary for 5
    .byte 0x7D                   @ Binary for 6
    .byte 0x07                   @ Binary for 7
    .byte 0x7F                   @ Binary for 8
    .byte 0x6F                   @ Binary for 9