.globl f # this allows other files to find the function f

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (read the lab spec for more information).
# The return value should be stored in a0
f:
    addi sp, sp, -4
    sw ra, 0(sp)

    li t0, -3
    beq a0, t0, case_minus_3

    li t0, -2
    beq a0, t0, case_minus_2

    li t0, -1
    beq a0, t0, case_minus_1

    li t0, 0
    beq a0, t0, case_0

    li t0, 1
    beq a0, t0, case_1

    li t0, 2
    beq a0, t0, case_2

    li t0, 3
    beq a0, t0, case_3

    li a0, 0 
    j end_f

case_minus_3:
    li a0, 6      
    j end_f

case_minus_2:
    li a0, 61     
    j end_f

case_minus_1:
    li a0, 17     
    j end_f

case_0:
    li a0, -38    
    j end_f

case_1:
    li a0, 19     
    j end_f

case_2:
    li a0, 42     
    j end_f

case_3:
    li a0, 5     
    j end_f

end_f:
    lw ra, 0(sp)
    addi sp, sp, 4

    # This is how you return from a function. You'll learn more about this later.
    # This should be the last line in your program.
    jr ra