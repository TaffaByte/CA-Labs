`timescale 1ns / 1ps
module switches (
    input clk, 
    input rst, 
    input readEnable,
    input [15:0] switches, output reg [31:0] readData
);
    always @(posedge clk) begin
        if (rst) readData <= 32'h0;
        else if (readEnable) readData <= {16'h0, switches};
    end
endmodule