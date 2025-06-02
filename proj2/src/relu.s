.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#    a0 (int*) is the pointer to the array
#    a1 (int)  is the # of elements in the array
# Returns:
#    None
# Exceptions:
#    - If the length of the array is less than 1,
#      this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    li a2, 0 # index of array
    li t0, 4 # size of elem


    li t4, 1
    blt a1, t4, error_length

loop_start:
    bge a2, a1, loop_end

    mul t2, a2, t0 
    add a3, a0, t2 
    lw t3, 0(a3)   

    blt t3, x0, store_zero 

loop_continue:
    addi a2, a2, 1
    j loop_start

store_zero:
    sw x0, 0(a3)   
    j loop_continue

loop_end:
    # Epilogue
    jr ra

error_length:
    li a0, 36          
    j exit