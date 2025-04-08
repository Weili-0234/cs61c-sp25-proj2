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
    addi sp, sp, -36
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    
    # Save filename pointer and row/col pointers
    mv s0, a0      # s0 = filename
    mv s1, a1      # s1 = pointer to rows
    mv s2, a2      # s2 = pointer to columns
    
    # Open the file with read permissions
    mv a0, s0      # a0 = filename
    li a1, 0       # a1 = 0 (read-only)
    jal ra, fopen
    mv s3, a0      # s3 = file descriptor
    
    # Check if fopen failed
    li t0, -1
    beq s3, t0, fopen_error
    
    # Read the number of rows
    mv a0, s3      # a0 = file descriptor
    mv a1, s1      # a1 = pointer to store rows
    li a2, 4       # a2 = read 4 bytes
    jal ra, fread
    
    # Check if fread failed
    li t0, 4
    bne a0, t0, fread_error
    
    # Read the number of columns
    mv a0, s3      # a0 = file descriptor
    mv a1, s2      # a1 = pointer to store columns
    li a2, 4       # a2 = read 4 bytes
    jal ra, fread
    
    # Check if fread failed
    li t0, 4
    bne a0, t0, fread_error
    
    # Calculate matrix size and allocate memory
    lw s4, 0(s1)   # s4 = rows
    lw s5, 0(s2)   # s5 = columns
    mul s6, s4, s5  # s6 = rows * columns
    slli s7, s6, 2  # s7 = rows * columns * 4 (bytes)
    
    # Allocate memory for matrix
    mv a0, s7      # a0 = size to allocate
    jal ra, malloc
    mv s7, a0      # s7 = pointer to allocated memory
    
    # Check if malloc failed
    beqz s7, malloc_fail
    
    # Read matrix elements
    mv a0, s3      # a0 = file descriptor
    mv a1, s7      # a1 = pointer to buffer
    slli a2, s6, 2  # a2 = rows * columns * 4 (bytes to read)
    jal ra, fread
    
    # Check if fread failed
    slli t0, s6, 2  # t0 = expected bytes read
    bne a0, t0, fread_error
    
    # Close the file
    mv a0, s3
    jal ra, fclose
    
    # Check if fclose failed
    li t0, -1
    beq a0, t0, fclose_error
    
    # Set return value
    mv a0, s7      # a0 = pointer to matrix
    
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36
    
    jr ra

malloc_fail:
    li a0, 26
    j exit

fopen_error:
    li a0, 27
    j exit
    
fclose_error:
    li a0, 28
    j exit

fread_error:
    li a0, 29
    j exit