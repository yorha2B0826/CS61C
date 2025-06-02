.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    li a2, 0
    li t0, 4
    li t5, 0
    li t4, 1
    blt a1, t4, error_length

loop_start:
    bge a2, a1, loop_end
    mul t1, a2, t0
    add t2, a0, t1
    lw t3, 0(t2)
    bge t3, t5, save_max

loop_continue:
    addi a2, a2, 1
    j loop_start

save_max:
    add t6, a2, x0
    add t5, t3, x0
    j loop_continue
    
loop_end:
    # Epilogue
    add a0, t6, x0
    jr ra
error_length:
    li a0, 36
    j exit