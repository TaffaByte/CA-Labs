`timescale 1ns / 1ps
module DataMemory (
    input             clk,
    input             rst,
    input             memWrite,
    input      [7:0]  address,
    input      [31:0] writeData,
    output     [31:0] readData
);
    reg [31:0] memory [0:511];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 512; i = i + 1)
                memory[i] <= 32'h0;
        end else if (memWrite) begin
            memory[address] <= writeData;
        end
    end

    assign readData = memory[address];
endmodule
