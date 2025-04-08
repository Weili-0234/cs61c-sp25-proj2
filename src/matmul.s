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
    # Error checks: if The height or width of either matrix is less than 1.
    bge zero a1 make_no_sense
    bge zero a2 make_no_sense
    bge zero a4 make_no_sense
    bge zero a5 make_no_sense
    # check if The number of columns (width) of the first matrix A 
    # is not equal to the number of rows (height) of the second matrix B.
    bne a2 a4 make_no_sense 
    # Prologue
    addi sp sp -44
    sw ra 0(sp)
    sw s0 4(sp) # s0 init as the pointer to the first mat
    sw s1 8(sp) # s1 always holds the pointer to the second mat
    sw s2 12(sp) # s2 init as the height of mat1, index for outer loop
    sw s3 16(sp) # s3 holds width of mat1 (== height of mat2)
    sw s4 20(sp) # s4 always holds width of mat2
    sw s5 24(sp) # s5 holds temporal ptr to start to arr1 (mat2)
    sw s6 28(sp) # s6 holds counter through width of output mat

    mv s0 a0
    
    mv s1 a3
    mv s5 a3
    
    mv s2 a1
    mv s3 a2
    
    mv s4 a5 # s4 always holds width of mat2
    mv s6 a5 # s6 holds counter through width of output mat
    
    li t0 0
    li t1 0
outer_loop_start:
    # iterate through nows of mat1
    bge zero s2 outer_loop_end
inner_loop_start: # iterate through a row in output mat
    bge zero s6 inner_loop_end
    # calls dot (modifies t0 - t4, does not modify a5, a6)
    # a0 (int*) is the pointer to the start of arr0
    # a1 (int*) is the pointer to the start of arr1
    # a2 (int)  is the number of elements to use
    # a3 (int)  is the stride of arr0
    # a4 (int)  is the stride of arr1
    sw t0 32(sp) # t0 stores row index of output mat
    sw t1 36(sp) # t1 stores column index of output mat
    sw a6 40(sp)
    mv a0 s0 # start of a row in mat1 (arr0)
    mv a1 s5
    mv a2 s3
    li a3 1
    mv a4 s4
    jal dot # a0 holds the dot product
    # recovers row and column index
    lw t0 32(sp)
    lw t1 36(sp) 
    lw a6 40(sp)
    mul t2 t0 s4
    add t2 t2 t1
    slli t2 t2 2 # t2 = (row_idx * k + column_idx) * 4
    add t2 t2 a6
    sw a0 0(t2)
    # 
    addi s5 s5 4
    addi s6 s6 -1
    addi t1 t1 1
    j inner_loop_start

inner_loop_end:
    addi t0 t0 1 # next row in output mat
    li t1 0 # first element in a row
    mv s5 s1 # restore s5 to start of mat2
    mv s6 s4 # restore s6 to width of mat2
    slli t3 s3 2
    add s0 s0 t3 # s0 now points to next line of mat1
    addi s2 s2 -1 # decrement row counter in output mat 
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra 0(sp)
    lw s0 4(sp) # s0 init as the pointer to the first mat
    lw s1 8(sp) # s1 always holds the pointer to the second mat
    lw s2 12(sp) # s2 init as the height of mat1, index for outer loop
    lw s3 16(sp) # s3 holds width of mat1 (== height of mat2)
    lw s4 20(sp) # s4 always holds width of mat2
    lw s5 24(sp) # s5 holds temporal ptr to start to arr1 (mat2)
    lw s6 28(sp)
    addi sp sp 44
    jr ra

make_no_sense:
    li a0 38
    j exit