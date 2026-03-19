`timescale 1ns / 1ps
module leds (
    input             clk,
    input             rst,
    input      [31:0] writeData,
    input             writeEnable,
    output     [15:0] leds
);
    reg [7:0] led_low;
    reg [7:0] led_high;

    always @(posedge clk) begin
        if (rst) begin
            led_low  <= 8'h0;
            led_high <= 8'h0;
        end else if (writeEnable) begin
            led_low  <= writeData[7:0];
            led_high <= writeData[15:8];
        end
    end

    assign leds = {led_high, led_low};
endmodule
