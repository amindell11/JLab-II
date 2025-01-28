@EECE 3200
@Arye Mindell
@display_clock subroutine: converts clock values to ascii and outputs them to terminal


.section .text
.global display_clock

display_clock:
    PUSH {r0, r5, r6, r7, lr}                 @ Save the current seconds counter value

    @ Calculate seconds for the display
    BL get_led_code           @ Call the subroutine to calculate display value
    MOV r5, r1                @ Store the seconds display code in r5

    @ Calculate minutes for the display
    MOV r0, r6                @ Load the minutes counter into r0
    BL get_led_code           @ Call the subroutine to calculate display value
    LSL r1, r1, #8           @ Shift the minutes display code left by 16 bits
    ORR r5, r1, r5            @ Combine minutes and seconds into r1

    @ Calculate hours for the display
    MOV r0, r7                @ Load the hours counter into r0
    BL get_led_code           @ Call the subroutine to calculate display value
    LSL r1, r1, #16           @ Shift the hours display code left by 16 bits
    ORR r1, r1, r5            @ Combine hours with minutes and seconds in R1

    @ Write the clock value to display

    POP {r0, r5, r6, r7, lr}                  @ Restore the seconds counter value
	Bx lr

@ Subroutine to calculate the seven-segment display value
get_led_code:
    PUSH {r4, lr}                 @ Save return address

    BL divide_by_10               @ Call the division subroutine
    @ After the call:
    @ r1 = tens digit (quotient)
    @ r0 = ones digit (remainder)

    @ Convert the ones digit to ascii
    MOV r2, r1                    @ Move tens digit to r2
    BL number_to_ascii         @ Call the function to get the segment code
    MOV r4, r1                    @ Store converted ones digit in R4

    @ Convert the tens digit to ascii
    MOV r0, r2
    BL number_to_ascii         @ Call the function to get the segment code
    LSL r1, r1, #4                @ Shift the tens digit value left by 4 bits

    @ Combine tens and ones digits into a single word
    ORR r1, r1, r4                @ Combine tens (shifted) and ones into r1

    POP {r4, lr}                  @ Restore return address
    BX lr                         @ Return to caller

number_to_ascii:
    PUSH {lr}                    @ Save return address
    CMP r0, #9                   @ Check if the number is greater than 9
    BHI invalid_input            @ Branch if invalid input

    ADD R1, R0, #48
    B return_value               @ Skip invalid case

invalid_input:
    MOV r1, #0                   @ Set r1 to 0 for invalid input (no segments lit)

return_value:
    POP {lr}                     @ Restore return address
    BX lr                        @ Return to caller

@subroutine to divide by 10 and save remainder (used to split digits)
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

    