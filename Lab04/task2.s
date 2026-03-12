.text
.globl main

main:
    li a0, 5                # Load argument N = 5
    jal ra, ntri            # Call ntri(5)
    
    # Print result
    li a7, 1                # ecall 1: print_int
    ecall                   # a0 already contains the result
    
    # Exit
    li a7, 10               # ecall 10: exit
    ecall

ntri:
    li, t0  , 1
    ble a0, t0, base_case

    addi sp, sp, -8
    sw ra, 4(sp)           # Save return address
    sw a0, 0(sp)           # Save argument N

    addi a0, a0, -1
    jal ra, ntri            # Recursive call ntri(N-1)

    lw t1, 0(sp)
    add a0, t1, a0

    lw ra, 4(sp)
    addi sp, sp 8
    ret

base_case:
    li a0, 1
    ret