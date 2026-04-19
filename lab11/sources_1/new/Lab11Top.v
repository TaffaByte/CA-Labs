`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2026 02:53:06 PM
// Design Name: 
// Module Name: Lab11Top
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


module Lab11Top (
    input wire clk, 
    input wire reset
);
    wire [31:0] pcIdx, pcIdxNext, pcIdxIncrement;
    wire [31:0] instruction, immediateValue;
    
    // Explicitly defining the missing wires from the original code
    wire        writeEnable, ALUSrc;
    wire [3:0]  ALUControlSignal;
    wire [31:0] writeData, readData1, readData2, ALUInput;
    
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];

    ProgramCounter    pc (.clk(clk), .reset(reset), .pc_in(pcIdxNext), .pc_out(pcIdx));
    pcAdder           pcAdd (.pc(pcIdx), .pc_next(pcIdxIncrement));
    InstructionMemory instMem (.ReadAddress(pcIdx), .Instruction(instruction));
    immGen            immediateGen (.inst(instruction), .imm(immediateValue));

    RegisterFile regFile (
        .clk(clk), .rst(reset), .WriteEnable(writeEnable),
        .rs1(rs1), .rs2(rs2), .rd(rd), 
        .WriteData(writeData), .readData1(readData1), .readData2(readData2)
    );

    mux2 #(32) ALUInputSelect (
        .d0(readData2), .d1(immediateValue), .sel(ALUSrc), .y(ALUInput)
    );

    ALU alu (
        .A(readData1), .B(ALUInput), .ALUControl(ALUControlSignal), 
        .ALUResult(), .zero() // Fixed missing semicolon here
    );
endmodule
