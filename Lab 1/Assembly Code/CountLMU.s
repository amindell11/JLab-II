.section .data
prompt_msg: .asciz "Please type text of 15 characters: \n"
result_msg: .asciz "There are %d instances of LMU\n"
input_buffer: .space 16       @ Space for 15 characters + null terminator

.section .bss
.lcomm count, 4             @ Variable to store count of LMU instances

.section .text
.global _start

_start:
    @ Print prompt message
    ldr r0, =prompt_msg
    bl print_string

    @ Read 15 characters from the keyboard
    ldr r0, =input_buffer
    mov r1, #15
    bl read_input

    @ Count LMU instances
    ldr r0, =input_buffer
    bl count_lmu
    ldr r1, =count
    ldr r1, [r1]

    @ Print result on the monitor
    ldr r0, =result_msg
    bl print_result

    @ Display count on LEDs
 @   mov r0, r1
 @   bl display_on_leds

    @ Repeat process indefinitely
    b _start

@ Function: print_string
@ r0: Address of null-terminated string to print
print_string:
    mov r7, #4             @ syscall: write
    mov r1, r0             @ string address
    mov r2, #40            @ max length to write
    mov r0, #1             @ file descriptor: stdout
    svc #0
    bx lr

@ Function: read_input
@ r0: Address to store input
@ r1: Number of bytes to read
read_input:
    mov r7, #3             @ syscall: read
    mov r2, r1             @ number of bytes to read
    mov r0, #0             @ file descriptor: stdin
    svc #0
    bx lr

@ Function: count_lmu
@ r0: Address of input buffer
count_lmu:
    push {r4, r5, r6, lr}
    ldr r1, =count
    mov r2, #0
    str r2, [r1]           @ Initialize count to 0

count_loop:
    ldrb r3, [r0], #1      @ Load byte and increment pointer
    cmp r3, #0             @ Check for null terminator
    beq count_done

    @ Compare with "LMU"
    cmp r3, #'L'
    bne count_loop
    ldrb r4, [r0]
    cmp r4, #'M'
    bne count_loop
    ldrb r5, [r0, #1]
    cmp r5, #'U'
    bne count_loop

    @ Check for word boundaries
    ldrb r6, [r0, #-2]     @ Previous character
    cmp r6, #' '
    bne count_loop
    ldrb r6, [r0, #3]      @ Next character
    cmp r6, #' '
    bne count_loop

    @ Increment count
    ldr r2, [r1]
    add r2, r2, #1
    str r2, [r1]

    add r0, r0, #2         @ Advance pointer past "MU"
    b count_loop

count_done:
    pop {r4, r5, r6, lr}
    bx lr

@ Function: print_result
@ r0: Address of result message format string
@ r1: Count of LMU instances
print_result:
    mov r2, r1             @ Pass count as parameter
    mov r7, #4             @ syscall: write
    mov r1, r0             @ Format string address
    svc #0
    bx lr

@ Function: display_on_leds
@ r0: Count of LMU instances
@ Display count on GPIO LEDs in binary format
@display_on_leds:
 @   mov r1, #0x20200000    @ GPIO base address
  @  mov r2, #0x1C          @ Offset for LED control
   @ str r0, [r1, r2]       @ Write count to LEDs
   @ bx lr
