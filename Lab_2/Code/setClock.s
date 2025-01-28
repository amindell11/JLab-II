@EECE 3200
@Arye Mindell
@setClock subroutine: accepts input from user to set the initial values of the clock

.text
.global set_clock
set_clock:
    MOV r0, #0                @ Initialize seconds counter to 0
    MOV r6, #58                @ Initialize minutes counter to 58
    MOV r7, #23                @ Initialize hours counter to 23
bx lr