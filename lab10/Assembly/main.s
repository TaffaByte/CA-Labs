# Lab 10 FSM Assembly Implementation
# Board: Basys3 (16 switches, 16 LEDs)
# Clock: 10 MHz

.equ SW_ADDR,      0x80000000  # UPDATE: Replace with your Address Decoding MMIO address
.equ LED_ADDR,     0x80000004  # UPDATE: Replace with your Address Decoding MMIO address

.text
.globl _start

_start:
    # 1. Initialize Stack Pointer
    # Points to the top of your Data Memory (Update if your data memory starts elsewhere)
    li sp, 0x00010000          

wait_input:
    # 2. Input Waiting State
    li t0, SW_ADDR
    lw a0, 0(t0)               # Read the switch value into argument register a0
    andi a0, a0, 0xFFFF        # Mask the lower 16 bits (since Basys3 has 16 switches)
    
    # If switch == 0, keep waiting (loop back)
    beqz a0, wait_input        

    # 3. Transition to Countdown State
    # Non-zero value captured. Call the countdown subroutine.
    call countdown_routine
    
    # When subroutine returns, jump back to waiting state
    j wait_input               


# ---------------------------------------------------------
# Subroutine: countdown_routine
# Description: Displays the value, delays, and decrements to 0.
# Arguments: a0 = initial captured switch value
# ---------------------------------------------------------
countdown_routine:
    # --- Stack Prologue ---
    addi sp, sp, -16           # Allocate 16 bytes on the stack
    sw ra, 12(sp)              # Save Return Address (ra)
    sw s0, 8(sp)               # Save saved-register (s0)

    # Move captured value to a safe register that survives the loop
    mv s0, a0                  

countdown_loop:
    # Output current count to LEDs
    li t1, LED_ADDR
    sw s0, 0(t1)

    # --- Software Delay Timer ---
    # At 10 MHz, 1 second is 10,000,000 clock cycles.
    # This loop takes 3 cycles per iteration (addi + bnez).
    # 10,000,000 / 3 = ~3,333,333 iterations.
    li t2, 3333333             
delay_loop:
    addi t2, t2, -1
    bnez t2, delay_loop

    # Decrement the FSM counter
    addi s0, s0, -1
    
    # If counter > 0, loop back to update LEDs and delay again
    bnez s0, countdown_loop

    # 4. Counter reached 0: Clear LEDs
    li t1, LED_ADDR
    sw zero, 0(t1)

    # --- Stack Epilogue ---
    lw s0, 8(sp)               # Restore saved-register (s0)
    lw ra, 12(sp)              # Restore Return Address (ra)
    addi sp, sp, 16            # Deallocate stack space
    ret                        # Return to caller