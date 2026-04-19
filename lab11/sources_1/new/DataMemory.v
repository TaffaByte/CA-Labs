`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2026 02:48:41 PM
// Design Name: 
// Module Name: DataMemory
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


module DataMemory (
    input  wire        clk, rst, memWrite,
    input  wire [ 7:0] address,
    input  wire [31:0] writeData,
    output wire [31:0] readData
);
    reg [31:0] memory [0:511];
    integer i;
    
    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset handled differently to allow BRAM inference
            for (i = 0; i < 512; i = i + 1) begin
                memory[i] <= 32'b0;
            end
        end else if (memWrite) begin
            memory[address] <= writeData;
        end
    end
    
    assign readData = memory[address];
endmodule