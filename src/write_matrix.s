.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

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
    
    # Save arguments
    mv s0, a0      # s0 = filename
    mv s1, a1      # s1 = pointer to matrix
    mv s2, a2      # s2 = rows
    mv s3, a3      # s3 = columns
    
    # Open file with write permissions
    mv a0, s0      # a0 = filename
    li a1, 1       # a1 = 1 (write-only)
    jal ra, fopen
    mv s4, a0      # s4 = file descriptor
    
    # Check if fopen failed
    li t0, -1
    beq s4, t0, fopen_error
    
    # Store rows and columns on stack for fwrite
    addi sp, sp, -8
    sw s2, 0(sp)   # Store rows at sp
    sw s3, 4(sp)   # Store columns at sp+4
    
    # Write number of rows
    mv a0, s4      # a0 = file descriptor
    mv a1, sp      # a1 = pointer to rows
    li a2, 1       # a2 = 1 element
    li a3, 4       # a3 = 4 bytes per element
    jal ra, fwrite
    
    # Check if fwrite failed
    li t0, 1
    bne a0, t0, fwrite_error
    
    # Write number of columns
    mv a0, s4      # a0 = file descriptor
    addi a1, sp, 4 # a1 = pointer to columns
    li a2, 1       # a2 = 1 element
    li a3, 4       # a3 = 4 bytes per element
    jal ra, fwrite
    
    # Check if fwrite failed
    li t0, 1
    bne a0, t0, fwrite_error
    
    # Clean up stack
    addi sp, sp, 8
    
    # Calculate total number of elements
    mul s5, s2, s3  # s5 = rows * columns
    
    # Write matrix data
    mv a0, s4      # a0 = file descriptor
    mv a1, s1      # a1 = pointer to matrix
    mv a2, s5      # a2 = rows * columns elements
    li a3, 4       # a3 = 4 bytes per element
    jal ra, fwrite
    
    # Check if fwrite failed
    bne a0, s5, fwrite_error
    
    # Close file
    mv a0, s4
    jal ra, fclose
    
    # Check if fclose failed
    li t0, -1
    beq a0, t0, fclose_error
    
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

fopen_error:
    li a0, 27
    j exit
    
fclose_error:
    li a0, 28
    j exit
    
fwrite_error:
    li a0, 30
    j exit
