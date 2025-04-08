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
    addi sp sp -8
    sw s0 0(sp) # s0 holds the current biggest number
    sw s1 4(sp) # s1 holds the index of the biggest number
    bge zero a1 malformed # if the length of the array is less than 1
    lw s0 0(a0) # initialize s0 as arr[0]
    li s1 0 # # initialize s1 as 0
    li t1 1 # initialize t1, the current index
    addi a1 a1 -1
loop_start:
    bge zero a1 loop_end # a1 is the loop counter
    slli t2 t1 2 
    add t2 t2 a0 # t2 = a0 + 4 * index
    lw t0 0(t2) # t0 holds the current number
    bge s0 t0 loop_continue # if prev_biggest >= curr, skip to next
    mv s0 t0
    mv s1 t1 
loop_continue:
    addi t1 t1 1
    addi a1 a1 -1
    j loop_start
loop_end:
    mv a0 s1
    lw s1 4(sp)
    lw s0 0(sp)
    addi sp sp 8
    jr ra

malformed:
    li a0 36
    j exit