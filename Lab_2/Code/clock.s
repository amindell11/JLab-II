@EECE 3200
@Arye Mindell
@clock main function: runs the main count loop of the clock. calls set_clock to initialize the clock and display_clock to print the clock output

.global _start
.extern set_clock
.extern sleep_one_second
.extern display_clock

_start:
    bl set_clock

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
    bl sleep_one_second       @ Pause for 1 second
    ADD r0, r0, #1            @ Increment the seconds counter
	bl display_clock
    B count_loop              @ Repeat the loop