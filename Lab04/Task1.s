.text
.globl main

main:
    addi x18, x18, 5    # int n = 5;
    addi x19, x19, 1    # int t1 = 1;
    addi x20, x20, 1    # int fact = 1;
    loop1:
        blt x18,x19, end
        mul x20, x18, x20   # fact *= n*fact
        sub x18, x18, x19
        beq x0, x0, loop1
end:
    j end

