`timescale 1ns / 1ps

module Switches (
    input  logic        clk,
    input  logic        rst,
    input  logic        readEnable,
    input  logic [15:0] switches,
    output logic [31:0] readData
);

    // On clock edge, zero-extend the 16-bit switches to 32-bit output
    always_ff @(posedge clk) begin
        if (rst) begin
            readData <= 32'h0;
        end else if (readEnable) begin
            // {16'b0, switches} automatically puts zeros in the upper 16 bits
            readData <= {16'h0000, switches};
        end
    end

endmodule
