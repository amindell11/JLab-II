@ text_processor.s
@ ARM Assembly program for Raspberry Pi 3B+ or 4.
@ Reads a text string, counts instances of "LMU", and displays the result on the monitor.

.cpu cortex-a72
.fpu neon-fp-armv8
.syntax unified

@Source code constants
.equ STDIN, 0
.equ STDOUT, 1

.section .rodata
.align 2
prompt:
    .asciz "Please enter a string of 15 characters: "
promptLength = . - prompt

result:
    .asciz "There are "         @ Message prefix
resultLength = . - result

instancesMsg:
    .asciz " instances of LMU\n" @ Message suffix
instancesMsgLength = . - instancesMsg

.section .bss
.align 2
inputBuffer:
    .space 16                  @ Buffer for 15 characters + null terminator
countBuffer:
    .space 12                  @ Buffer to store ASCII representation of count

.text
.align 2
.global main
main:

loop:
    mov r7, #4                @ #4 for write
    mov r0, #STDOUT           @ file descriptor: STDOUT
    ldr r1, =prompt           @ message pointer
    mov r2, #promptLength     @ length of message
    svc 0                     @ make the syscall write
    mov r7, #3                @ #3 for read
    mov r0, #STDIN            @ file descriptor: STDIN
    ldr r1, =inputBuffer      @ buffer pointer
    mov r2, #16               @ max length
    svc 0                     @ make the syscall
    ldr r0, =inputBuffer      @ Load the address of inputBuffer
    add r0, r0, #15           @ Move pointer to the 16th byte
    mov r1, #0                @ Null terminator (ASCII 0)
    strb r1, [r0]             @ Store null terminator
    ldr r0, =inputBuffer      @ Reset pointer to start of input buffer
    mov r1, #0                @ Initialize count of "LMU"

process:
    ldrb r2, [r0], #1         @ Load a byte and advance pointer
    cmp r2, #0                @ Check for null terminator
    beq doneProcessing        @ Exit if end of string
    cmp r2, #'L'              @ Check if the character is 'L'
    bne process               @ If not 'L', move to next character
    ldrb r2, [r0], #1         @ Load next character and advance pointer
    cmp r2, #'M'              @ Check if the character is 'M'
    bne continueAfterL        @ If not 'M', continue from character after 'L'
    ldrb r2, [r0], #1         @ Load next character and advance pointer
    cmp r2, #'U'              @ Check if the character is 'U'
    bne continueAfterM        @ If not 'U', continue from character after 'M'
    add r1, r1, #1            @ Increment counter for "LMU"
    b process                 @ Continue processing

continueAfterM:
    sub r0, r0, #2            @ Backtrack pointer to after 'L'
    b process                 @ Continue processing

continueAfterL:
    sub r0, r0, #1            @ Backtrack pointer to after 'L'
    b process                 @ Continue processing

doneProcessing:

    mov r0, r1                @ Copy count to r0
    ldr r1, =countBuffer      @ Pointer to buffer for ASCII representation
    bl int_to_ascii           @ Convert integer to ASCII string
    mov r7, #4                @ #4 for write
    mov r0, #STDOUT           @ file descriptor: STDOUT
    ldr r1, =result           @ Message prefix
    mov r2, #resultLength     @ Max length
    svc 0                     @ Make syscall
    mov r7, #4                @ #4 for write
    mov r0, #STDOUT           @ file descriptor: STDOUT
    ldr r1, =countBuffer      @ Message prefix
    mov r2, #12               @ Max length
    svc 0                     @ Make syscall
    mov r7, #4                @ #4 for write
    mov r0, #STDOUT           @ file descriptor: STDOUT
    ldr r1, =instancesMsg     @ Message suffix
    mov r2, #instancesMsgLength @ Length of suffix
    svc 0                     @ Make syscall
   
    ldr r1, =countBuffer      @ Message prefix
    ldr r0, [r1]
    bl binLED

    b loop                    @ Repeat everything

int_to_ascii:
    mov r2, #10               @ Base 10
    mov r3, #0                @ Index for buffer (write from the end)

ascii_loop:
    udiv r4, r0, r2           @ Divide r0 by 10 (r4 = quotient)
    mls r5, r4, r2, r0        @ Remainder: r5 = r0 - (r4 * r2)
    add r5, r5, #'0'          @ Convert digit to ASCII
    strb r5, [r1, r3]         @ Store ASCII digit in buffer
    add r3, r3, #1            @ Increment buffer index
    mov r0, r4                @ Update r0 with quotient
    cmp r0, #0                @ Check if quotient is 0
    bne ascii_loop            @ Repeat if not
    mov r0, r3                @ r0 = length of ASCII string
    sub r2, r3, #1            @ r2 = index of last character
    mov r3, #0                @ r3 = index of first character
    bx lr
