`timescale 1ns / 1ps

// branchAdder - unchanged from Lab 11
//   Computes branch_target = PC + (imm << 1)
module branchAdder (
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    output wire [31:0] branch_target
);
    assign branch_target = pc + (imm << 1);
endmodule
