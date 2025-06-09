.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    li t0, 1
    blt a1, t0, error_dimensions
    blt a2, t0, error_dimensions
    blt a4, t0, error_dimensions
    blt a5, t0, error_dimensions
    bne a2, a4, error_dimensions
    
    # Prologue
    addi sp, sp, -40
    sw ra, 36(sp)
    sw s0, 32(sp)
    sw s1, 28(sp)
    sw s2, 24(sp)
    sw s3, 20(sp)
    sw s4, 16(sp)
    sw s5, 12(sp)
    sw s6, 8(sp)
    sw s7, 4(sp)
    
    mv s2, a0  
    mv s3, a1  
    mv s4, a2  
    mv s5, a3  
    mv s6, a5  
    mv s7, a6 
    
    li s0 ,0

outer_loop_start:
    bge s0, s3, outer_loop_end
    li s1, 0


inner_loop_start:
    bge s1, s6, inner_loop_end
    mul t0, s0, s4
    slli t0, t0, 2
    add a0, s2, t0
    
    slli t1, s1, 2
    add a1, s5, t1
    
    mv a2, s4
    li a3, 1
    mv a4, s6
    jal dot
    
    mul t0, s0, s6
    add t0, t0, s1
    slli t0, t0, 2
    add t1, s7, t0
    sw a0, 0(t1)
    
    addi s1, s1, 1
    j inner_loop_start

inner_loop_end:
    addi s0, s0, 1
    j outer_loop_start



outer_loop_end:


    # Epilogue
    lw ra, 36(sp)
    lw s0, 32(sp)
    lw s1, 28(sp)
    lw s2, 24(sp)
    lw s3, 20(sp)
    lw s4, 16(sp)
    lw s5, 12(sp)
    lw s6, 8(sp)
    lw s7, 4(sp)
    addi sp, sp, 40

    jr ra
    
error_dimensions:
    li a0, 38
    j exit
