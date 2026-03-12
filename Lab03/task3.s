.globl
.text
main:
    addi x24, x0, 2 # x24 = 0 + 2 = 2
    addi x25, x0, 1 # x25 = 0 + 1 = 1
    addi x26, x0, 5 # x26 = 0 + 5 = 5

    sw x24, 0x100(x0) # Value of x24 is stored at memory address 0x100
    sw x25, 0x104(x0) # Value of x25 is stored at memory address 0x104
    sw x26, 0x108(x0) # Value of x26 is stored at memory address 0x108

    addi x10, x0, 0x100 # x10 now holds the base address of v at 0x100
    addi x11, x0, 1 # x11 = 1 which is k.

    jal x1, Swapping # Function call to Swapping and the return address is stored in x1.
    j exit
    Swapping:
        addi sp, sp, -16 # Allocating the stack
        sw x1, 12(sp) # Return address for line 34 of jalr
        sw x5, 8(sp)
        sw x6, 4(sp)
        sw x7, 0(sp)

        slli x6, x11, 2
        add x6, x10, x6 # Getting memory address of v[k]

        lw x5, 0(x6) # The value of x6 which is 5 from memory address 0x104 is loaded into x5
        lw x7, 4(x6)
        sw x7, 0(x6)
        sw x5, 4(x6) # x5 will store the value of 1 at memory address 0x108 completing a swap

        lw x7, 0(sp)
        lw x6, 4(sp)
        lw x5, 8(sp)
        lw x1, 12(sp)

        addi sp, sp, 16 # Deallocating the stack

        jalr x0, 0(x1) # Returns swap
    exit:
end:
    j end