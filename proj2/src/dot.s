.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    li t0, 1
    blt a2, t0, error_length1
    blt a3, t0, error_length2
    blt a4, t0, error_length2
    li t0, 4
    mul a3, a3, t0
    mul a4, a4, t0
    li t2, 0
    li t6, 0

loop_start:
    bge t2, a2, loop_end
    mul t3, t2, a3
    mul t4, t2, a4
    add t3, a0, t3
    add t4, a1, t4
    lw t0, 0(t3)
    lw t1, 0(t4)
    mul t5, t0, t1
    add t6, t6, t5
    addi t2, t2, 1
    j loop_start

loop_end:
    add a0, t6, x0
    # Epilogue
    jr ra
    
error_length1:
    li a0, 36
    j exit
    
error_length2:
    li a0, 37
    j exit
