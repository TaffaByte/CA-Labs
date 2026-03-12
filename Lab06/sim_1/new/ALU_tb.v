`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 07:26:31 AM
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire        Zero;

    // Instantiate DUT
    ALU uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin

        // ADD
        A = 32'h00000010; B = 32'h00000020;
        ALUControl = 4'b0000; #10;

        // SUB
        A = 32'h00000030; B = 32'h00000010;
        ALUControl = 4'b0001; #10;

        // SUB (equal)
        A = 32'h00000005; B = 32'h00000005;
        ALUControl = 4'b0001; #10;

        // AND
        A = 32'hFF00FF00; B = 32'h0F0F0F0F;
        ALUControl = 4'b0010; #10;

        // OR
        ALUControl = 4'b0011; #10;

        // XOR
        A = 32'hAAAAAAAA; B = 32'h55555555;
        ALUControl = 4'b0100; #10;

        // SLL
        A = 32'h00000001; B = 32'h00000004;
        ALUControl = 4'b0101; #10;

        // SRL
        A = 32'h00000080; B = 32'h00000004;
        ALUControl = 4'b0110; #10;

        // Default
        A = 32'h12345678; B = 32'h9ABCDEF0;
        ALUControl = 4'b1111; #10;

        // ADD overflow case
        A = 32'hFFFFFFFF; B = 32'h00000001;
        ALUControl = 4'b0000; #10;

        $finish;

    end

endmodule
