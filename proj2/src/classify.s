.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    # Prologue
    li t0, 5
    bne a0, t0, incorrect_args

    addi sp, sp, -64
    sw ra, 60(sp)
    sw s0, 56(sp)
    sw s1, 52(sp)
    sw s2, 48(sp)
    sw s3, 44(sp)
    sw s4, 40(sp)
    sw s5, 36(sp)
    sw s6, 32(sp)
    sw s7, 28(sp)

    mv s0, a2 
    mv s7, a1
    
    # Read pretrained m0
    lw a0, 4(s7)
    addi a1, sp, 0
    addi a2, sp, 4
    jal ra, read_matrix
    mv s1, a0

    # Read pretrained m1
    lw a0, 8(s7)
    addi a1, sp, 8
    addi a2, sp, 12
    jal ra, read_matrix
    mv s2, a0

    # Read input matrix
    lw a0, 12(s7)
    addi a1, sp, 16
    addi a2, sp, 20
    jal ra, read_matrix
    mv s3, a0

    # Compute h = matmul(m0, input)
    lw t0, 0(sp)
    lw t1, 20(sp)
    mul a0, t0, t1
    slli a0, a0, 2
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s4, a0

    # Call matmul for h = m0 * input
    mv a0, s1    
    lw a1, 0(sp)
    lw a2, 4(sp)
    mv a3, s3
    lw a4, 16(sp)
    lw a5, 20(sp)
    mv a6, s4
    jal ra, matmul

    # Compute h = relu(h)
    lw t0, 0(sp)    
    lw t1, 20(sp)   
    mul t2, t0, t1
    mv a0, s4
    mv a1, t2
    jal ra, relu

    # Compute o = matmul(m1, h)
    lw t0, 8(sp)    
    lw t1, 20(sp)  
    mul a0, t0, t1
    slli a0, a0, 2
    jal ra, malloc
    beq a0, x0, malloc_error
    mv s5, a0       

    # Call matmul for o = m1 * h
    mv a0, s2       
    lw a1, 8(sp)    
    lw a2, 12(sp)   
    mv a3, s4      
    lw a4, 0(sp)    
    lw a5, 20(sp)   
    mv a6, s5       
    jal ra, matmul

    # Write output matrix o
    lw a0, 16(s7)   
    mv a1, s5      
    lw a2, 8(sp)   
    lw a3, 20(sp)   
    jal ra, write_matrix

    # Compute and return argmax(o)
    lw t0, 8(sp)    
    lw t1, 20(sp)   
    mul t2, t0, t1  
    mv a0, s5       
    mv a1, t2      
    jal ra, argmax
    mv s6, a0       
    bne s0, x0, skip_print
    mv a0, s6
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char
skip_print:

    
    mv a0, s1       
    jal ra, free
    mv a0, s2      
    jal ra, free
    mv a0, s3       
    jal ra, free
    mv a0, s4       
    jal ra, free
    mv a0, s5       
    jal ra, free

    
    mv a0, s6       

    lw ra, 60(sp)
    lw s0, 56(sp)
    lw s1, 52(sp)
    lw s2, 48(sp)
    lw s3, 44(sp)
    lw s4, 40(sp)
    lw s5, 36(sp)
    lw s6, 32(sp)
    lw s7, 28(sp)
    addi sp, sp, 64

    jr ra

incorrect_args:
    li a0, 31
    j exit

malloc_error:
    li a0, 26
    j exit
