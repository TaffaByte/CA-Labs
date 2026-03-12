.text
.globl main

main:
    li s0, 0x100     

    li t0, 23
    sw t0, 0(s0)
    li t0, 12
    sw t0, 4(s0)
    li t0, 5
    sw t0, 8(s0)
    li t0, 44
    sw t0, 12(s0)
    li t0, 98
    sw t0, 16(s0)
    li t0, 53
    sw t0, 20(s0)
    li t0, 6
    sw t0, 24(s0)
    li t0, 89
    sw t0, 28(s0)
    li t0, 32
    sw t0, 32(s0)
    li t0, 65
    sw t0, 36(s0)

    li s1, 10    

outer:
    li t0, 0            # swapped = 0
    li t1, 1            # i = 1

inner:
    bge t1, s1, check_outer

    slli t2, t1, 2
    add t3, s0, t2       # &a[i]
    lw  t4, 0(t3)        # a[i]
    lw  t5, -4(t3)       # a[i-1]

    ble  t5, t4, noswap

    sw  t4, -4(t3)
    sw  t5, 0(t3)
    li  t0, 1

noswap:
    addi t1, t1, 1
    j inner

check_outer:
    bnez t0, outer
    ret