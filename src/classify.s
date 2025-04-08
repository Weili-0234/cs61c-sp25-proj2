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
    addi sp, sp, -96
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    
    # Save args
    mv s0, a0          # s0 = argc
    mv s1, a1          # s1 = argv
    mv s2, a2          # s2 = silent mode flag
    
    # Stack offsets for matrix data:
    # 24(sp): m0_rows (pointer)
    # 28(sp): m0_cols (pointer)
    # 32(sp): m0 matrix (pointer)
    # 36(sp): m1_rows (pointer)
    # 40(sp): m1_cols (pointer)
    # 44(sp): m1 matrix (pointer)
    # 48(sp): input_rows (pointer)
    # 52(sp): input_cols (pointer)
    # 56(sp): input matrix (pointer)
    # 60(sp): output filepath
    # 64(sp): h_rows
    # 68(sp): h_cols  
    # 72(sp): h (pointer)
    # 76(sp): o_rows
    # 80(sp): o_cols
    # 84(sp): o (pointer)
    # 88-92(sp): temporary storage
    
    # Store output file path on stack for later use
    lw t0, 16(s1)      # Load argv[4]
    sw t0, 60(sp)      # Store the output filepath pointer
    
    # Check for correct number of command line args (should be 5)
    li t0, 5
    bne s0, t0, incorrect_args
    
    # Read pretrained m0
    # Allocate memory for m0 rows and columns
    li a0, 4
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 24(sp)      # Store pointer to m0_rows
    
    li a0, 4
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 28(sp)      # Store pointer to m0_cols
    
    # Read m0 matrix
    lw a0, 4(s1)       # a0 = m0 filepath (argv[1])
    lw a1, 24(sp)      # a1 = pointer to m0_rows
    lw a2, 28(sp)      # a2 = pointer to m0_cols
    jal ra, read_matrix
    sw a0, 32(sp)      # Store pointer to m0 matrix
    
    # Read pretrained m1
    # Allocate memory for m1 rows and columns
    li a0, 4
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 36(sp)      # Store pointer to m1_rows
    
    li a0, 4
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 40(sp)      # Store pointer to m1_cols
    
    # Read m1 matrix
    lw a0, 8(s1)       # a0 = m1 filepath (argv[2])
    lw a1, 36(sp)      # a1 = pointer to m1_rows
    lw a2, 40(sp)      # a2 = pointer to m1_cols
    jal ra, read_matrix
    sw a0, 44(sp)      # Store pointer to m1 matrix
    
    # Read input matrix
    # Allocate memory for input rows and columns
    li a0, 4
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 48(sp)      # Store pointer to input_rows
    
    li a0, 4
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 52(sp)      # Store pointer to input_cols
    
    # Read input matrix
    lw a0, 12(s1)      # a0 = input filepath (argv[3])
    lw a1, 48(sp)      # a1 = pointer to input_rows
    lw a2, 52(sp)      # a2 = pointer to input_cols
    jal ra, read_matrix
    sw a0, 56(sp)      # Store pointer to input matrix
    
    # Compute h = matmul(m0, input)
    # Check matrix dimensions for compatibility
    lw t0, 28(sp)      # Load pointer to m0_cols
    lw t0, 0(t0)       # t0 = m0_cols
    lw t1, 48(sp)      # Load pointer to input_rows
    lw t1, 0(t1)       # t1 = input_rows
    bne t0, t1, free_and_exit  # If m0_cols != input_rows, exit
    
    # Allocate memory for h
    lw t0, 24(sp)      # Load pointer to m0_rows
    lw t0, 0(t0)       # t0 = m0_rows
    sw t0, 64(sp)      # Store h_rows = m0_rows
    
    lw t1, 52(sp)      # Load pointer to input_cols
    lw t1, 0(t1)       # t1 = input_cols
    sw t1, 68(sp)      # Store h_cols = input_cols
    
    mul t2, t0, t1     # t2 = m0_rows * input_cols
    slli t2, t2, 2     # t2 = (m0_rows * input_cols) * 4 bytes
    
    mv a0, t2
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 72(sp)      # Store h pointer
    
    # Call matmul(m0, input, h)
    lw a0, 32(sp)      # a0 = m0
    lw t0, 24(sp)      # Load pointer to m0_rows
    lw a1, 0(t0)       # a1 = m0_rows
    lw t0, 28(sp)      # Load pointer to m0_cols
    lw a2, 0(t0)       # a2 = m0_cols
    lw a3, 56(sp)      # a3 = input
    lw t0, 48(sp)      # Load pointer to input_rows
    lw a4, 0(t0)       # a4 = input_rows
    lw t0, 52(sp)      # Load pointer to input_cols
    lw a5, 0(t0)       # a5 = input_cols
    lw a6, 72(sp)      # a6 = h
    jal ra, matmul
    
    # Compute h = relu(h)
    lw a0, 72(sp)      # a0 = h
    lw t0, 64(sp)      # t0 = h_rows
    lw t1, 68(sp)      # t1 = h_cols
    mul a1, t0, t1     # a1 = h_rows * h_cols
    jal ra, relu
    
    # Compute o = matmul(m1, h)
    # Check matrix dimensions for compatibility
    lw t0, 40(sp)      # Load pointer to m1_cols
    lw t0, 0(t0)       # t0 = m1_cols
    lw t1, 64(sp)      # t1 = h_rows
    bne t0, t1, free_and_exit  # If m1_cols != h_rows, exit
    
    # Allocate memory for o
    lw t0, 36(sp)      # Load pointer to m1_rows
    lw t0, 0(t0)       # t0 = m1_rows
    sw t0, 76(sp)      # Store o_rows = m1_rows
    
    lw t1, 68(sp)      # t1 = h_cols
    sw t1, 80(sp)      # Store o_cols = h_cols
    
    mul t2, t0, t1     # t2 = m1_rows * h_cols
    slli t2, t2, 2     # t2 = (m1_rows * h_cols) * 4 bytes
    
    mv a0, t2
    jal ra, malloc
    beqz a0, malloc_fail   # Check if malloc failed
    sw a0, 84(sp)      # Store o pointer
    
    # Call matmul(m1, h, o)
    lw a0, 44(sp)      # a0 = m1
    lw t0, 36(sp)      # Load pointer to m1_rows
    lw a1, 0(t0)       # a1 = m1_rows
    lw t0, 40(sp)      # Load pointer to m1_cols
    lw a2, 0(t0)       # a2 = m1_cols
    lw a3, 72(sp)      # a3 = h
    lw a4, 64(sp)      # a4 = h_rows
    lw a5, 68(sp)      # a5 = h_cols
    lw a6, 84(sp)      # a6 = o
    jal ra, matmul
    
    # Write output matrix o
    lw a0, 60(sp)      # a0 = output filepath
    lw a1, 84(sp)      # a1 = o pointer
    lw a2, 76(sp)      # a2 = o_rows
    lw a3, 80(sp)      # a3 = o_cols
    jal ra, write_matrix
    
    # Compute and return argmax(o)
    lw a0, 84(sp)      # a0 = o
    lw t0, 76(sp)      # t0 = o_rows
    lw t1, 80(sp)      # t1 = o_cols
    mul a1, t0, t1     # a1 = o_rows * o_cols
    jal ra, argmax
    
    # Save argmax result
    mv s3, a0          # Store the argmax result
    
    # If enabled, print argmax(o) and newline
    bnez s2, skip_print
    mv a0, s3
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char
skip_print:
    
    # Free allocated memory
    lw a0, 24(sp)      # m0_rows pointer
    jal ra, free
    
    lw a0, 28(sp)      # m0_cols pointer
    jal ra, free
    
    lw a0, 32(sp)      # m0 matrix pointer
    jal ra, free
    
    lw a0, 36(sp)      # m1_rows pointer
    jal ra, free
    
    lw a0, 40(sp)      # m1_cols pointer
    jal ra, free
    
    lw a0, 44(sp)      # m1 matrix pointer
    jal ra, free
    
    lw a0, 48(sp)      # input_rows pointer
    jal ra, free
    
    lw a0, 52(sp)      # input_cols pointer
    jal ra, free
    
    lw a0, 56(sp)      # input matrix pointer
    jal ra, free
    
    lw a0, 72(sp)      # h pointer
    jal ra, free
    
    lw a0, 84(sp)      # o pointer
    jal ra, free
    
    # Set return value
    mv a0, s3
    
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 96
    
    jr ra

free_and_exit:
    # Free memory and exit with error
    lw a0, 24(sp)      # m0_rows pointer
    jal ra, free
    
    lw a0, 28(sp)      # m0_cols pointer
    jal ra, free
    
    lw a0, 32(sp)      # m0 matrix pointer
    jal ra, free
    
    lw a0, 36(sp)      # m1_rows pointer
    jal ra, free
    
    lw a0, 40(sp)      # m1_cols pointer
    jal ra, free
    
    lw a0, 44(sp)      # m1 matrix pointer
    jal ra, free
    
    lw a0, 48(sp)      # input_rows pointer
    jal ra, free
    
    lw a0, 52(sp)      # input_cols pointer
    jal ra, free
    
    lw a0, 56(sp)      # input matrix pointer
    jal ra, free
    
    li a0, 31
    j exit

incorrect_args:
    li a0, 31
    j exit

malloc_fail:
    li a0, 26
    j exit