# i x22, sum x23
# address 0x200 - 4 byte integers

li x22, 0
li x23, 0

# k x23
li x24, 10
li x25, 0x200

loop:
    slli x10, x22, 2
    add x10, x10, x25
    sw x22, 0(x10) # a[i] = i
    add x23, x23 , x22
    addi x22, x22, 1
    blt x22, x24, loop
    