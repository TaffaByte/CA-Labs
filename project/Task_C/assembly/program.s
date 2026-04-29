
# Task B — Isolated Verification of 3 New RV32I Instructions
#
# This program tests each new instruction independently of Task C.
#
# Three new instructions of DIFFERENT types are added.lui,jal and bne

# ----------------------------------------------------------------------------
# Setup:
#   addi x10, x0, 5             ; 0x000   x10 = 5
#   addi x11, x0, 5             ; 0x004   x11 = 5
#   addi x12, x0, 7             ; 0x008   x12 = 7
#
# ----------------------------------------------------------------------------
# test 1 - LUI (U-type)
#   lui  x20, 0xABCDE           ; 0x00C   x20 = 0xABCDE000
#   PASS condition: x20 == 0xABCDE000
#
# ----------------------------------------------------------------------------
# test 2 - JAL (J-type)
#   jal  x1, +12                ; 0x010   PC -> 0x01C, x1 = 0x014
#   addi x21, x0, 99            ; 0x014   <-- SKIPPED (proves jump taken)
#   addi x21, x0, 99            ; 0x018   <-- SKIPPED
#   addi x22, x0, 1             ; 0x01C   landing point (x22 = 1)
#   PASS conditions:
#     x1  == 0x014   (return address = PC+4 saved correctly)
#     x21 == 0       (skipped instructions did NOT execute)
#     x22 == 1       (landing instruction DID execute)
#
# ----------------------------------------------------------------------------
# test 3 - BNE NOT taken (operands equal)
#   bne  x10, x11, +8           ; 0x020   x10==x11=5, NOT taken
#   addi x23, x0, 1             ; 0x024   executes (x23 = 1)
#   PASS condition: x23 == 1   (proves fall-through when equal)
#
# test 3b - BNE TAKEN (operands not equal)
#   bne  x10, x12, +8           ; 0x028   x10=5, x12=7, TAKEN
#   addi x24, x0, 99            ; 0x02C   <-- SKIPPED
#   addi x25, x0, 1             ; 0x030   landing point (x25 = 1)
#   PASS conditions:
#     x24 == 0       (skipped instruction did NOT execute)
#     x25 == 1       (landing instruction DID execute)
#
# ----------------------------------------------------------------------------
# halt:
#   jal  x0, 0                  ; 0x034   spin forever
