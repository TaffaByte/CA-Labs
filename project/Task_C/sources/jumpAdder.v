`timescale 1ns / 1ps
// jumpAdder - for JAL: target = PC + imm  (imm already includes byte alignment)

module jumpAdder (
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    output wire [31:0] jump_target
);
    assign jump_target = pc + imm;
endmodule
