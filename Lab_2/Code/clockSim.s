    .section .text
    .global _start

    .extern sleep_one_second  @ Declare the external subroutine

    .equ DISPLAY_BASE, 0xFF200020  @ Memory location for seven-segment display

_start:
    MOV r0, #0                @ Initialize register r0 to 0

test_loop:
    BL sleep_one_second       @ Call the subroutine to sleep for 1 second
    EOR r0, r0, #1            @ Toggle r0 value between 0 and 1

    LDR r1, =DISPLAY_BASE     @ Load base address of the seven-segment display
    STR r0, [r1]              @ Write r0 to the display (toggle segments)

    B test_loop               @ Repeat the loop
