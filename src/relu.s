.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp sp -4
    sw ra 0(sp)
    bge zero a1 malformed # if the length of the array is less than 1
    li t1 0 # initialize t1, the offset register  
loop_start:
    bge zero a1 loop_end # a1 is the loop counter
    add t0 a0 t1 # t0 is the address to the int
    lw t2 0(t0) # load the int into t2
    bge t2 zero loop_continue # if the int is >= 0, move to next
    sw zero 0(t0)
loop_continue:
    addi t1 t1 4
    addi a1 a1 -1 
    j loop_start
loop_end:
    # Epilogue
    lw ra 0(sp)
    addi sp sp 4

    jr ra

malformed:
    li a0 36
    j exit