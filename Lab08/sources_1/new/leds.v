`timescale 1ns / 1ps

module Leds (
    input  logic        clk,
    input  logic        rst,
    input  logic        writeEnable,
    input  logic [31:0] writeData,
    output logic [15:0] leds
);

    // Single 16-bit register is cleaner than two 8-bit registers
    always_ff @(posedge clk) begin
        if (rst) begin
            leds <= 16'h0000;
        end else if (writeEnable) begin
            // Directly mapping the lower half of the 32-bit bus
            leds <= writeData[15:0];
        end
    end

endmodule