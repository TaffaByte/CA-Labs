.text
.globl main
main:
    li x09, 5                       # a = x09
    li x10, 0                       # b = x10
    addi x09, x10, 32               # a = b + 32
    add x11, x09, x10               # d = a + b
    addi x11, x11, -5               # d = d - 5
    sub x05, x09, x11               # temp1 = a - d
    sub x06, x10, x09               # temp2 = b - a
    add x07, x05, x06               # temp3 = temp1 + temp2
    add x12, x07, x11               # e = temp3 + d
    add x5, x09, x10                # temp1 = a + b
    add x6, x11, x12
    add x12, x5, x6
end:
    j end            # Infinite loop to halt program    