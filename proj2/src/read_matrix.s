.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp) 
    sw s2, 16(sp) 
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)
    
    mv s1, a1
    mv s2, a2

    li a1, 0
    jal ra, fopen
    li t0, -1
    beq t0, a0, fopen_error
    mv s0, a0
    
    mv a0, s0       
    mv a1, s1       
    li a2, 4        
    jal ra, fread
    li t0, 4
    bne a0, t0, fread_error 

    mv a0, s0       
    mv a1, s2       
    li a2, 4        
    jal ra, fread
    li t0, 4
    bne a0, t0, fread_error
    
    lw s4, 0(s1)    
    lw s5, 0(s2) 
    mul t0, s4, s5  
    slli a0, t0, 2  
    mv s6, a0      
    jal ra, malloc
    beq a0, x0, malloc_error 
    mv s3, a0
    
    mv a0, s0       
    mv a1, s3       
    mv a2, s6      
    jal ra, fread
    bne a0, s6, fread_error 

    
    mv a0, s0       
    jal ra, fclose
    li t0, -1
    beq a0, t0, fclose_error

    
    mv a0, s3

    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    jr ra

fopen_error:
    li a0, 27
    j exit
fread_error:
    li a0, 29
    j exit
malloc_error:
    li a0, 26
    j exit
fclose_error:
    li a0, 28
    j exit