.text
.globl main
main:
    #Address
    li x10, 0x100       #a
    li x11, 0x200       #b
    li x12, 0x300       #c

    addi x1, x0, 0x100
    addi x2, x0, 1
    sb x2, 0(x1)
    addi x2, x0, -2
    sb x2, 1(x1)
    addi x2, x0, 3
    sb x2, 2(x1)
    addi x2, x0, -4
    sb x2, 3(x1)

    addi x1, x0, 0x200
    addi x2, x0, 100
    sh x2, 0(x1)
    addi x2, x0, 200
    sh x2, 2(x1)
    addi x2, x0, -300
    sh x2, 4(x1)
    addi x2, x0, -400
    sh x2, 6(x1)

    #i = 0
    lb x5, 0(x10)       #load byte from a (mem) to x5 (register)
    lh x6, 0(x11)       #load halfword from b (mem) to x6 (register)
    add x7, x5, x6      # i = a + b
    sw x7, 0(x12)       # store i at address 0x300

    #i = 1
    lb x5, 1(x10)
    lh x6, 2(x11)
    add x7, x5, x6      # i = a + b
    sw x7, 4(x12)       # store i at address 0x304

    #i = 2
    lb x5, 2(x10)
    lh x6, 4(x11)
    add x7, x5, x6      # i = a + b
    sw x7, 8(x12)       # store i at address 0x308

    #i = 3
    lb x5, 3(x10)
    lh x6, 6(x11)
    add x7, x5, x6      # i = a + b
    sw x7, 12(x12)      # store i at address 0x30C


end:    
    j end