`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2026 02:51:12 PM
// Design Name: 
// Module Name: MainControl
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


module MainControl (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg  [1:0] ALUOp,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        MemtoReg,
    output reg        Branch
);
    // Refactored to use a concatenated bus for much cleaner assignment
    always @(*) begin
        // {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch}
        case(opcode)
            7'b0110011: {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 8'b1_10_0_0_0_0_0; // R-type
            7'b0010011: {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 8'b1_11_0_0_1_0_0; // I-type ALU
            7'b0000011: {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 8'b1_00_1_0_1_1_0; // Load
            7'b0100011: {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 8'b0_00_0_1_1_0_0; // Store
            7'b1100011: {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 8'b0_01_0_0_0_0_1; // Branch
            default:    {RegWrite, ALUOp, MemRead, MemWrite, ALUSrc, MemtoReg, Branch} = 8'b0_00_0_0_0_0_0; // Default
        endcase
    end
endmodule
