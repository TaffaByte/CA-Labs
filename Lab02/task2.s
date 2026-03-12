li x10, 1
li x11, 2
li x12, 3
li x13, 4

# x x20, a x21, b x22, c x23

li x22, 4
li x23, 2
li x20, 4

beq x20, x10, one
beq x20, x11, two
beq x20, x12, three
beq x20, x13, four
li x20, 0 
j exit
one:
    add x21, x22, x23
    j exit
two:
    sub x21, x22, x23
    j exit
three:
    mul x21, x22, x11
    j exit
four:
    div x21, x22, x11
    j exit
exit:
    j exit