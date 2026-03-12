    .text
    .globl main

main:
    addi x10, x0, 10
    addi x11, x0, 7
    addi x12, x0, 4
    addi x13, x0, 2

    jal  x1, leaf_example

    addi x11, x10, 0
    li   x10, 1
    ecall

    j    exit


leaf_example:
    addi sp, sp, -24
    sd   x18, 0(sp)
    sd   x19, 8(sp)
    sd   x20, 16(sp)

    add  x18, x10, x11
    add  x19, x12, x13
    sub  x10, x18, x19    # result directly in x10 (no need for x20 here)

    ld   x18, 0(sp)
    ld   x19, 8(sp)
    ld   x20, 16(sp)
    addi sp, sp, 24

    jalr x0, 0(x1)


exit:
    j    exit