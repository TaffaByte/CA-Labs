`timescale 1ns / 1ps
// DataMemory - unchanged from Lab 11
// addresses are used as direct word indices.
module DataMemory (
    input  wire        clk, rst, memWrite,
    input  wire [ 7:0] address,
    input  wire [31:0] writeData,
    output wire [31:0] readData
);
    reg [31:0] memory [0:511];
    integer i;

    initial begin
        for (i = 0; i < 512; i = i + 1) memory[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 512; i = i + 1) memory[i] <= 32'b0;
        end else if (memWrite) begin
            memory[address] <= writeData;
        end
    end

    assign readData = memory[address];
endmodule
