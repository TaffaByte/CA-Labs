    .text
    .globl main

main:
    addi x10, x0, 10    # g = 10
    addi x11, x0, 7     # h = 7
    addi x12, x0, 4     # i = 4
    addi x13, x0, 2     # j = 2

    jal  x1, leaf

    addi x11, x10, 0
    li x10, 1
    ecall

    j exit


leaf:
    addi sp, sp, -24       # 3 registers × 8 bytes = 24 is usually enough
    sw   x18, 0(sp)
    sw   x19, 8(sp)
    sw   x20, 16(sp)

    add  x18, x10, x11
    add  x19, x12, x13
    sub  x20, x18, x19
    mv   x10, x20

    lw   x18, 0(sp)
    lw   x19, 8(sp)
    lw   x20, 16(sp)
    addi sp, sp, 24
    jalr x0, 0(x1)

exit:
    j exit