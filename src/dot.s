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
    addi sp sp -4
    sw s0 0(sp)
    # Prologue
    bge zero a2 ele_error
    bge zero a3 stride_error
    bge zero a4 stride_error
    li s0 0 # s3 holds the sum, init as 0
    li t3 0 # t3 is the index in arr0
    li t4 0 # t4 is the index in arr1
loop_start:
    bge zero a2 loop_end
    slli t1 t3 2
    add t1 t1 a0
    lw t1 0(t1) # t1 holds element in arr0
    slli t2 t4 2
    add t2 t2 a1
    lw t2 0(t2) # t2 holds element in arr1
    mul t0 t1 t2
    add s0 s0 t0
    # 
    add t3 t3 a3
    add t4 t4 a4
    addi a2 a2 -1
    j loop_start
loop_end:
    mv a0 s0
    # Epilogue
    lw s0 0(sp)
    addi sp sp 4
    jr ra
    
ele_error:
    li a0 36
    j exit
    
stride_error:
    li a0 37
    j exit
