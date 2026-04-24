# Part C Assembly: Sum of an Array
#   Computes sum = 1+2+3+4+5 = 15 (0x0000000F)
#
#   Uses the 3 new instructions added in Part B:
#     - LUI (U-type)  : loads 0x00010000 into x18 (demo / observable)
#     - JAL (J-type)  : calls sum_loop, also used for jumps & halt loop
#     - BNE (B-type)  : loop-while-not-equal in sum_loop
#
#
# main:                                   ; PC
#   addi  x5,  x0, 1            ; 0x000   array[0]
#   addi  x6,  x0, 2            ; 0x004   array[1]
#   addi  x7,  x0, 3            ; 0x008   array[2]
#   addi  x28, x0, 4            ; 0x00C   array[3]
#   addi  x29, x0, 5            ; 0x010   array[4]
#   lui   x18, 0x00010          ; 0x014   x18 = 0x00010000  (LUI demo)
#   sw    x5,  0(x0)            ; 0x018
#   sw    x6,  4(x0)            ; 0x01C
#   sw    x7,  8(x0)            ; 0x020
#   sw    x28, 12(x0)           ; 0x024
#   sw    x29, 16(x0)           ; 0x028
#   addi  x10, x0, 0            ; 0x02C   base = 0
#   addi  x11, x0, 5            ; 0x030   N    = 5
#   addi  x12, x0, 0            ; 0x034   sum  = 0
#   addi  x14, x0, 0            ; 0x038   i    = 0
#   addi  x16, x0, 0            ; 0x03C   offset = 0
#   jal   x1, sum_loop          ; 0x040   JAL demo: call sum_loop
#
# after_sum:
#   add   x13, x12, x0          ; 0x044   x13 = sum (15) -> visible on outputs
#   jal   x0, halt              ; 0x048   jump to halt
#
# sum_loop:
#   add   x17, x10, x16         ; 0x04C   addr = base + offset
#   lw    x15, 0(x17)           ; 0x050   load array[i]
#   add   x12, x12, x15         ; 0x054   sum += array[i]
#   addi  x14, x14, 1           ; 0x058   i++
#   addi  x16, x16, 4           ; 0x05C   offset += 4
#   bne   x14, x11, sum_loop    ; 0x060   BNE demo: loop while i != N
#   jal   x0, after_sum         ; 0x064   "return"
#
# halt: keeps re-running "add x13, x12, x0" so ALU output stays at 15
#       and the LEDs steady-state to 0x000F (15) on the FPGA.
#   add   x13, x12, x0          ; 0x068   ALUResult = 15
#   jal   x0, halt              ; 0x06C   loop back to 0x068
