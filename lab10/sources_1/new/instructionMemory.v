`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2026 11:34:15 AM
// Design Name: 
// Module Name: instructionMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  [OPERAND_LENGTH:0] instAddress,
    output reg [31:0]         instruction
);

    reg [7:0] memory [0:255];

    // Byte-addressable, little-endian read
    always @(*) begin
        instruction = {memory[instAddress+3], memory[instAddress+2],
                       memory[instAddress+1], memory[instAddress]};
    end

    // Helper task to write 32-bit instructions into byte-addressable memory
    task set_inst;
        input integer addr;
        input [31:0] inst;
        begin
            memory[addr]   = inst[7:0];
            memory[addr+1] = inst[15:8];
            memory[addr+2] = inst[23:16];
            memory[addr+3] = inst[31:24];
        end
    endtask

    integer i;
    initial begin
        // Clear all memory
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 8'h00;
        end

        // main: 
        set_inst(0,   32'h2000_0413); // 0x000: addi x8, x0, 0x200       (li x8, 0x200 - LED addr)
        set_inst(4,   32'h3000_0493); // 0x004: addi x9, x0, 0x300       (li x9, 0x300 - switch addr)
        set_inst(8,   32'h4000_0913); // 0x008: addi x18, x0, 0x400      (li x18, 0x400 - reset addr)
        set_inst(12,  32'h00A0_0293); // 0x00C: addi x5, x0, 10          (test setup: x5 = 10)
        set_inst(16,  32'h0054_A023); // 0x010: sw x5, 0(x9)             (test setup: store to switches)

        // idle:
        set_inst(20,  32'h0004_A383); // 0x014: lw x7, 0(x9)             (read switches)
        set_inst(24,  32'hFE03_8EE3); // 0x018: beq x7, x0, idle         (if switches == 0, keep waiting)
        set_inst(28,  32'h0003_8513); // 0x01C: addi x10, x7, 0          (mv x10, x7 - pass count as arg)
        set_inst(32,  32'h0080_00EF); // 0x020: jal x1, countdown        (call countdown subroutine)
        set_inst(36,  32'hFF1F_F06F); // 0x024: jal x0, idle             (j idle - loop back)

        // countdown:
        set_inst(40,  32'hFF01_0113); // 0x028: addi sp, sp, -16         (allocate stack)
        set_inst(44,  32'h0011_2623); // 0x02C: sw x1, 12(sp)            (save ra)
        set_inst(48,  32'h0051_2423); // 0x030: sw x5, 8(sp)             (save x5)
        set_inst(52,  32'h0061_2223); // 0x034: sw x6, 4(sp)             (save x6)
        set_inst(56,  32'h0081_2023); // 0x038: sw x8, 0(sp)             (save x8)
        set_inst(60,  32'h0005_0293); // 0x03C: addi x5, x10, 0          (mv x5, x10 - x5 = counter)

        // count_loop:
        set_inst(64,  32'h0054_2023); // 0x040: sw x5, 0(x8)             (display counter on LEDs)
        set_inst(68,  32'h0202_8063); // 0x044: beq x5, x0, count_done   (if counter == 0, done)
        set_inst(72,  32'h0009_2303); // 0x048: lw x6, 0(x18)            (read reset button)
        set_inst(76,  32'h0003_1C63); // 0x04C: bne x6, x0, count_done   (if reset pressed, exit)
        set_inst(80,  32'hFFF2_8293); // 0x050: addi x5, x5, -1          (decrement counter)
        set_inst(84,  32'h0010_0313); // 0x054: addi x6, x0, 1           (li x6, 1 - delay init)

        // delay:
        set_inst(88,  32'hFFF3_0313); // 0x058: addi x6, x6, -1          (decrement delay counter)
        set_inst(92,  32'hFE03_1EE3); // 0x05C: bne x6, x0, delay        (loop delay)
        set_inst(96,  32'hFE1F_F06F); // 0x060: jal x0, count_loop       (j count_loop)

        // count_done: 
        set_inst(100, 32'h0004_2023); // 0x064: sw x0, 0(x8)             (clear LEDs)
        set_inst(104, 32'h0001_2403); // 0x068: lw x8, 0(sp)             (restore x8)
        set_inst(108, 32'h0041_2303); // 0x06C: lw x6, 4(sp)             (restore x6)
        set_inst(112, 32'h0081_2283); // 0x070: lw x5, 8(sp)             (restore x5)
        set_inst(116, 32'h00C1_2083); // 0x074: lw x1, 12(sp)            (restore ra)
        set_inst(120, 32'h0101_0113); // 0x078: addi sp, sp, 16          (deallocate stack)
        set_inst(124, 32'h0000_8067); // 0x07C: jalr x0, 0(x1)           (return)
    end

endmodule
