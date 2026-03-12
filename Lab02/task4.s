.text
.globl main
main:
# a - x5
# b - x6
# i - x7
# j - x29


# Base address of D - x10
li x10, 0x200
li x11, 0 # i = 0

loop1:
    li x12, 0 # j = 0
    loop2:
        slli x13, x12, 2 # temp = j * 4
        add x13, x13, x10 # temp reg to store base address
        add x14, x11, x12 # temp = i + j
        sw x14, 0(x13) # D[Address] = temp1
        addi x12, x12, 1 # j++
        blt x6, x12, loop2
    addi x11, x11, 1 # i++
    blt x5, x11, loop1


end:
    j end